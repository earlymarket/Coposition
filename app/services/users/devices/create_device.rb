module Users::Devices
  class CreateDevice
    attr_reader :device

    def initialize(user, params)
      @user = user
      @name = params[:name]
      @uuid = params[:uuid]
      @device = if @uuid.present?
                  Device.find_by(uuid: @uuid)
                else
                  Device.new
                end
    end

    def save?
      @device && @device.user.nil? && @device.construct(@user, @name)
    end

    def error
      return 'UUID does not match an existing device' unless @device
      return 'Device is registered to another user' if @device.id
      "You already have a device with the name #{@name}"
    end
  end
end
