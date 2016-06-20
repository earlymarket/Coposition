module Users
  class DevicesPresenter
    attr_reader :devices
    attr_reader :device
    attr_reader :checkins
    attr_reader :filename
    attr_reader :config

    def initialize(user, params, action)
      @user = user
      @params = params
      send action
    end

    def index
      @devices = @user.devices.order(:id).includes(:permissions)
    end

    def show
      @device = Device.find(@params[:id])
      @checkins = @device.checkins.to_csv
      @filename = "device-#{@device.id}-checkins-#{Date.today}.csv"
    end

    def shared
      @device = Device.find(@params[:id])
      @checkin = @device.checkins.first
    end

    def info
      @device = Device.find(@params[:id])
      @config = @device.config
    end

    def index_gon
      {
        checkins: gon_index_checkins,
        current_user_id: @user.id,
        devices: @devices,
        permissions: @devices.map(&:permissions).inject(:+)
      }
    end

    def show_gon
      {
        checkins: @device.checkins,
        current_user_id: @user.id
      }
    end

    def shared_gon
      {
        device: @device.public_info,
        user: @device.user.public_info_hash,
        checkin: gon_shared_checkin
      }
    end

    private

    def gon_index_checkins
      @user.checkins.calendar_data if @user.checkins.exists?
    end

    def gon_shared_checkin
      @checkin.reverse_geocode!.replace_foggable_attributes.public_info if @checkin
    end
  end
end
