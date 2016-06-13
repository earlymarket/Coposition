class Users::DevicesController < ApplicationController
  before_action :authenticate_user!, except: :shared
  before_action :published?, only: :shared
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'index')
    gon.push(@presenter.index_gon)
    @presenter.devices.geocode_last_checkins
  end

  def show
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'show')
    gon.push(@presenter.show_gon)
    respond_to do |format|
      format.html { flash[:notice] = 'Right click on the map to checkin' }
      format.csv { send_data @presenter.checkins, filename: @presenter.filename }
    end
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def shared
    presenter = ::Users::DevicesPresenter.new(current_user, params, 'shared')
    gon.push(presenter.shared_gon)
  end

  def info
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'info')
  end

  def create
    result = Users::Devices::CreateDevice.new(current_user, default_developer, allowed_params)
    if result.save?
      device = result.device
      gon.checkins = create_checkin(device)
      redirect_to user_device_path(id: device.id)
    else
      redirect_to new_user_device_path, notice: result.error
    end
  end

  def destroy
    Checkin.where(device: params[:id]).delete_all
    Device.find(params[:id]).destroy
    flash[:notice] = 'Device deleted'
    redirect_to user_devices_path
  end

  def update
    result = ::Users::Devices::UpdateDevice.new(params)
    @device = result.update_device
    is_json = request.format.json?
    if @device.errors.any? && is_json
      render status: 400, json: @device.errors.messages
    elsif is_json
      render status: 200, json: {}
    end
    flash[:notice] = result.notice
  end

  private

  def allowed_params
    params.require(:device).permit(:uuid, :name, :delayed)
  end

  def create_checkin(device)
    device.checkins.create(checkin_params) if params[:create_checkin].present?
  end

  def checkin_params
    { lng: params[:location].split(',').first, lat: params[:location].split(',').last }
  end

  def require_ownership
    return if user_owns_device?
    flash[:notice] = 'You do not own that device'
    redirect_to root_path
  end

  def published?
    redirect_to root_path, notice: 'Device is not shared' unless Device.find(params[:id]).published?
  end

  def default_developer
    return FactoryGirl.create(:developer) if Rails.env.test?
    Developer.find_by(api_key: Rails.application.secrets.coposition_api_key)
  end
end
