module Users
  class DevicesPresenter
    attr_reader :devices
    attr_reader :device
    attr_reader :checkins
    attr_reader :filename

    def initialize(user, params, action)
      @user = user
      @params = params
      send action
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

    def index
      @devices = @user.devices.order(:id).includes(:developers, :permitted_users, :permissions)
    end

    def show
      @device = Device.find(@params[:id])
      @checkins = @device.checkins.to_csv
      @filename = "device-#{@device.id}-checkins-#{Date.today}.csv"
    end

    def download_checkins
      send_data @device.checkins.to_csv, filename: "device-#{@device.id}-checkins-#{Date.today}.csv"
    end

    private

    def gon_index_checkins
      @user.checkins.calendar_data if @user.checkins.exists?
    end
  end
end
