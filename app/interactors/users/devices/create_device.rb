module Users::Devices
  class CreateDevice
    include Interactor

    delegate :user, :developer, :params, to: :context

    def call
      @device = new_device(allowed_params[:uuid])
      error = device_error(allowed_params[:name])
      if error.present?
        context.fail!(error: error)
      else
        context.device = construct_device
        context.checkin = create_checkin
        @device.notify_subscribers('new_device', @device)
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

    def device_error(device_name)
      if @device.blank?
        "UUID does not match an existing device"
      elsif @device.user.present?
        "Device is registered to another user"
      elsif user.devices.where(name: device_name).present?
        "You already have a device with the name #{device_name}"
      end
    end

    def construct_device
      allowed_params[:name]&.tr!(" ", "_")
      @device.update(allowed_params.merge(user: user))
      create_device_permissions
      create_device_config
      @device
    end

    def create_device_permissions
      @device.developers << user.developers
      @device.permitted_users << user.friends
    end

    def create_device_config
      developer.configs.create(device: @device) unless @device.config
    end

    def create_checkin
      @device.checkins.create(checkin_params) if params[:create_checkin]
    end

    def checkin_params
      { lng: params[:location].split(',').first, lat: params[:location].split(',').last }
    end

    def allowed_params
      params.require(:device).permit(:name, :uuid, :icon, :fogged, :delayed, :published, :cloaked, :alias)
    end
  end
end
