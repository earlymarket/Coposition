module Users::Checkins
  class BatchCreateCheckins
    include Interactor

    delegate :device, :post_content, to: :context

    def call
      checkins = device.checkins.transaction do
        checkins = JSON.parse(post_content).map do |checkin_hash|
          checkin_create(checkin_hash)
        end
        Checkin.import checkins
      end
      context.checkins = Checkin.find(checkins.ids)
    end

    private

    def checkin_create(hash)
      checkin = Checkin.new(hash.slice("lat", "lng", "created_at", "fogged"))
      raise ActiveRecord::Rollback && context.fail! unless valid_hash(checkin)
      checkin.assign_values
      checkin
    end

    def valid_hash(checkin)
      checkin.lat? && checkin.lng?
    end
  end
end
