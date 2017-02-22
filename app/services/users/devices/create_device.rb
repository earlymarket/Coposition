module Users::Devices
  class CreateDevice
    attr_reader :device
    attr_reader :checkin

    def initialize(user, developer, params)
      @user = user
      @developer = developer
      @params = params
      @name = allowed_params[:name]
      @uuid = allowed_params[:uuid]
      @device = if @uuid.present?
                  Device.find_by(uuid: @uuid)
                else
                  Device.new
                end
    end

    def save?
      return false unless @device && @device.user.nil? && construct
      @checkin = @device.checkins.create(checkin_params) if @params[:create_checkin]
      @developer.configs.create(device: @device) unless @device.config
      @device.notify_subscribers('new_device', @device)
      true
    end

    def error
      return 'UUID does not match an existing device' unless @device
      return 'Device is registered to another user' if @device.id
      "You already have a device with the name #{@name}"
    end

    private

    def construct
      return false unless @device.update(user: @user, name: @name)
      @device.update(allowed_params)
      @device.developers << @user.developers
      @device.permitted_users << @user.friends
      true
    end

    def checkin_params
      { lng: @params[:location].split(',').first, lat: @params[:location].split(',').last }
    end

    def allowed_params
      @params.require(:device).permit(:name, :uuid, :icon, :fogged, :delayed, :published, :cloaked, :alias)
    end
  end
end
