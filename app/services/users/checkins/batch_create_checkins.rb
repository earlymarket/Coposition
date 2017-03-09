module Users::Checkins
  class BatchCreateCheckins
    attr_reader :post_content
    attr_reader :device

    def initialize(device, post_content)
      @device = device
      @post_content = post_content
    end

    def success
      device.checkins.transaction do
        checkins = JSON.parse(post_content).map do |checkin_hash|
          checkin_create(checkin_hash)
        end
        Checkin.import checkins
      end
    end

    private

    def checkin_create(hash)
      checkin = Checkin.new(hash.slice("lat", "lng", "created_at", "fogged"))
      raise ActiveRecord::Rollback unless valid_hash(checkin)
      checkin.assign_values
      checkin
    end

    def valid_hash(checkin)
      checkin.lat? && checkin.lng?
    end
  end
end
