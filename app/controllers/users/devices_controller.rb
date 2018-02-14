class Users::DevicesController < ApplicationController
  before_action :authenticate_user!, :correct_url_user?, except: %i[shared devices download]
  before_action :published?, only: :shared
  before_action :require_ownership, only: %i[show destroy update]
  before_action :url_redirect, only: :devices

  def index
    @devices_index_presenter = ::Users::Devices::DevicesIndexPresenter.new(current_user, params)
    gon.push(@devices_index_presenter.index_gon)
  end

  def devices
    redirect_to(user_devices_path(current_user))
  end

  def show
    @device_show_presenter = ::Users::Devices::DevicesShowPresenter.new(current_user, params)
    gon.push(@device_show_presenter.show_gon)

    respond_to do |format|
      format.html
      format.any(:csv, :gpx, :geojson) do
        create_activity
        send_data @device_show_presenter.checkins, filename: @device_show_presenter.filename
      end
    end
  end

  def download
    user = User.find(params[:user_id])
    @device_show_presenter = ::Users::Devices::DevicesShowPresenter.new(user, params)
    send_data @device_show_presenter.checkins, filename: @device_show_presenter.filename
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def shared
    @devices_shared_presenter = ::Users::Devices::DevicesSharedPresenter.new(current_user, params)
    gon.push(@devices_shared_presenter.shared_gon)
  end

  def info
    @devices_info_presenter = ::Users::Devices::DevicesInfoPresenter.new(current_user, params)
  end

  def remote_checkin
    device = current_user.devices.find(params[:id])
    return unless device

    Firebase::Push.call(
      topic: device.user.id,
      content_available: true,
      data: {
        body: device.id.to_s,
        title: "Remote check-in"
      }
    )
    flash[:notice] = "Remote check-in request sent"
    redirect_to user_devices_path
  end

  def create
    result = Users::Devices::CreateDevice.call(user: current_user,
                                               developer: Developer.default(coposition: true),
                                               params: params)
    if result.success?
      gon.checkins = result.checkin
      redirect_to user_device_path(id: result.device.id)
    else
      redirect_to new_user_device_path, notice: result.error
    end
  end

  def destroy
    Device.find(params[:id]).destroy
    DeleteDeviceWorker.perform_async(params[:id])
    flash[:notice] = "Device deleted"
    redirect_to user_devices_path
  end

  def update
    result = ::Users::Devices::UpdateDevice.call(params: params)
    @device = result.device
    flash[:notice] = result.notice

    return unless request.format.json?

    if result.success?
      render status: 200, json: {}
    else
      render status: 400, json: result.error
    end
  end

  private

  def create_activity
    CreateActivity.call(
      entity: @device_show_presenter.device,
      action: :show,
      owner: current_user,
      params: { format: params[:format], count: @device_show_presenter.device.checkins.count }
    )
  end

  def require_ownership
    return if user_owns_device?

    flash[:notice] = "You do not own that device"
    redirect_to root_path
  end

  def published?
    device = Device.find(params[:id])

    return if device.published? && !device.cloaked?

    redirect_to root_path, notice: "Could not find shared device"
  end
end
