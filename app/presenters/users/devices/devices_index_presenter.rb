module Users::Devices
  class DevicesIndexPresenter < ApplicationPresenter
    attr_reader :user
    attr_reader :devices

    def initialize(user, params)
      @user = user
      @params = params
      @devices = index_devices
    end

    def index_devices
      user_devices.geocode_last_checkins
      device_ids = user_devices.last_checkins.map { |checkin| checkin["device_id"] }
      devices = user_devices.index_by(&:id).values_at(*device_ids)
      devices += user_devices.includes(:permissions)
      devices.uniq.paginate(page: @params[:page], per_page: 5)
    end

    def index_gon
      {
        checkins: gon_index_checkins,
        current_user_id: user.id,
        devices: devices,
        permissions: devices.map { |device| device.permissions.not_coposition_developers }.inject(:+)
      }
    end

    private

    def user_devices
      @user_devices ||= user.devices
    end

    def gon_index_checkins
      checkins = user_devices.map do |device|
        device.past_checkins.first.as_json.merge(device: device.name) if device.past_checkins.exists?
      end
      checkins.compact.sort_by { |checkin| checkin["created_at"] }.reverse
    end
  end
end
