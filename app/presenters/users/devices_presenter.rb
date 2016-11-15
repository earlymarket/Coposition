module Users
  class DevicesPresenter
    attr_reader :user
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
      devices = @user.devices
      devices.geocode_last_checkins
      device_ids = devices.last_checkins.map { |checkin| checkin['device_id'] }
      devices = devices.index_by(&:id).values_at(*device_ids)
      devices += @user.devices.includes(:permissions)
      @devices = devices.uniq.paginate(page: @params[:page], per_page: 5)
    end

    def show
      @device = Device.find(@params[:id])
      if @params[:download] == 'csv'
        @checkins = @device.checkins.to_csv
        @filename = "device-#{@device.id}-checkins-#{Date.today}.csv"
      elsif @params[:download] == 'geojson'
        @checkins = @device.checkins.to_geo_json
        @filename = "device-#{@device.id}-checkins-#{Date.today}.json"
      end
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
        permissions: @devices.map { |device| device.permissions.not_coposition_developers }.inject(:+)
      }
    end

    def show_gon
      {
        checkins: show_checkins,
        device: @device.id,
        current_user_id: @user.id,
        total: @device.checkins.count
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
      checkins = @user.devices.map do |device|
        device.checkins.first.as_json.merge(device: device.name) if device.checkins.exists?
      end.compact
      checkins.sort_by { |checkin| checkin['created_at'] }.reverse
    end

    def gon_shared_checkin
      @checkin.reverse_geocode!.replace_foggable_attributes.public_info if @checkin
    end

    def show_checkins
      @device.checkins.paginate(page: 1, per_page: 1000)
             .select(:id, :lat, :lng, :created_at, :address, :fogged, :fogged_area)
    end
  end
end
