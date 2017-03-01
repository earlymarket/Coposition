class Users::DevicesController < ApplicationController
  before_action :authenticate_user!, :correct_url_user?, except: :shared
  before_action :published?, only: :shared
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'index')
    gon.push(@presenter.index_gon)
  end

  def show
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'show')
    gon.push(@presenter.show_gon)
    respond_to do |format|
      format.html { flash[:notice] = 'Right click on the map to check-in' }
      format.any(:csv, :gpx, :geojson) { send_data @presenter.checkins, filename: @presenter.filename }
    end
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def shared
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'shared')
    gon.push(@presenter.shared_gon)
  end

  def info
    presenter = ::Users::DevicesPresenter.new(current_user, params, 'info')
    @device = presenter.device
    @config = presenter.config
  end

  def create
    result = Users::Devices::CreateDevice.new(current_user, Developer.default(coposition: true), allowed_params)
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
    # is_json = request.format.json?
    respond_to do |format|
      format.js { flash[:notice] = result.notice }
      format.json do
        if @device.errors.any?
          render status: 400, json: @device.errors.messages
        else
          render status: 200, json: {}
        end
      end
    end
  end

  private

  def allowed_params
    params.require(:device).permit(:uuid, :name, :delayed, :icon)
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
    device = Device.find(params[:id])
    return if device.published? && !device.cloaked?
    redirect_to root_path, notice: 'Could not find shared device'
  end
end
