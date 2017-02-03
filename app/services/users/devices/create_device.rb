module Users::Devices
  class CreateDevice
    attr_reader :device

    def initialize(user, developer, params)
      @user = user
      @developer = developer
      @name = params[:name]
      @uuid = params[:uuid]
      @icon = params[:icon]
      @device = if @uuid.present?
                  Device.find_by(uuid: @uuid)
                else
                  Device.new
                end
    end

    def save?
      if @device && @device.user.nil? && @device.construct(@user, @name, @icon)
        @developer.configs.create(device: @device) unless @device.config
        @device.notify_subscribers('new_device', @device)
        true
      end
    end

    def error
      return 'UUID does not match an existing device' unless @device
      return 'Device is registered to another user' if @device.id
      "You already have a device with the name #{@name}"
    end
  end
end
