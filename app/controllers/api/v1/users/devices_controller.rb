class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:switch_privilege_for_developer, :switch_all_privileges_for_developer]

  before_action :authenticate, :check_user_approved_developer
  before_action :find_user, :check_user, only: [:switch_privilege_for_developer, :switch_all_privileges_for_developer]

  def index
    list = []
    @user.devices.except(:fogged).map do |devc|
      if devc.privilege_for(@dev) == "complete"
        list << devc.device_checkin_hash
      end
    end
    respond_with list
  end

  def show
    list = []
    @user.devices.where(id: params[:id]).except(:fogged).map do |devc|
      if devc.privilege_for(@dev) == "complete"
        list << devc.device_checkin_hash
      else
        return head status: :unauthorized
      end
    end
    respond_with list
  end

  def switch_privilege_for_developer
    device = Device.where(id: params[:id], user: @user).first
    developer = Developer.where(id: params[:developer_id]).first
    if device && developer
      device.change_privilege_for(developer, device.reverse_privilege_for(developer))
      device.reverse_privilege_for(developer)
      render status: 200, json: device.device_developer_privileges.where(developer: developer)
    else
      render status: 404, json: { message: 'Device/Developer not found' }
    end
  end

  def switch_all_privileges_for_developer
    devices = @user.devices
    developer = Developer.where(id: params[:developer_id]).first
    privileges = []
    if devices && developer
      devices.each do |device|
        device.change_privilege_for(developer, device.reverse_privilege_for(developer))
        device.privilege_for(developer)
        device.reverse_privilege_for(developer)
        privileges << device.device_developer_privileges.where(developer: developer)
      end
      render status: 200, json: privileges
    else
      render status: 404, json: { message: 'Device/Developer not found' }
    end
  end

  private

    def check_user
      unless current_user?(params[:user_id])
        render status: 403, json: { message: 'Incorrect User' }
      end
    end

end