module Users::Devices
  class CreateDevice
    include Interactor

    delegate :user, :developer, :params, to: :context

    def call
      device = new_device(allowed_params[:uuid])
      device_name = allowed_params[:name]
      error = device_error(device, device_name)
      if error.present?
        context.fail!(error: error)
      else
        construct_device(device, device_name)
        context.device = device
        context.checkin = create_checkin(device)
      end
    end

    private

    def new_device(uuid)
      if uuid.present?
        Device.find_by(uuid: uuid)
      else
        Device.new
      end
    end

    def device_error(device, device_name)
      if device.blank?
        'UUID does not match an existing device'
      elsif device.user.present?
        'Device is registered to another user'
      elsif Device.where(user: user, name: device_name).present?
        "You already have a device with the name #{device_name}"
      end
    end

    def construct_device(device, device_name)
      device.update(user: user, name: device_name)
      device.update(allowed_params)
      device.developers << user.developers
      device.permitted_users << user.friends
      developer.configs.create(device: device) unless device.config
      device.notify_subscribers('new_device', device)
    end

    def create_checkin(device)
      device.checkins.create(checkin_params) if params[:create_checkin]
    end

    def checkin_params
      { lng: params[:location].split(',').first, lat: params[:location].split(',').last }
    end

    def allowed_params
      params.require(:device).permit(:name, :uuid, :icon, :fogged, :delayed, :published, :cloaked, :alias)
    end
  end
end
