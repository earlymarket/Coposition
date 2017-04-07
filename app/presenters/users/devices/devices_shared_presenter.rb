module Users::Devices
  class DevicesSharedPresenter < ApplicationPresenter
    attr_reader :user
    attr_reader :device

    def initialize(user, params)
      @user = user
      @device = Device.find(params[:id])
      checkin.first.reverse_geocode! if checkin.present?
    end

    def shared_gon
      {
        device: device.public_info,
        user: device.user.public_info_hash,
        checkin: gon_shared_checkin
      }
    end

    private

    def checkin
      @checkin ||= device.checkins.before(device.delayed.to_i.minutes.ago).limit(1)
    end

    def gon_shared_checkin
      return unless checkin.present?
      if device.fogged?
        checkin.select("id", "created_at", "updated_at", "device_id", "fogged_lat AS lat", "fogged_lng AS lng",
          "fogged_city AS address", "fogged_city AS city", "fogged_country_code AS postal_code",
          "fogged_country_code AS country_code")[0]
      else
        checkin.select("id", "created_at", "updated_at", "device_id", "output_lat AS lat", "output_lng AS lng",
          "output_address AS address", "output_city AS city", "output_postal_code AS postal_code",
          "output_country_code AS country_code")[0]
      end
    end
  end
end
