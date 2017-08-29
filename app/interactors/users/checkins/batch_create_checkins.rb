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
      create_activity(checkins)
      context.checkins = Checkin.find(checkins.ids)
    end

    private

    def create_activity(checkins)
      CreateActivity.call(entity: device,
                          action: :batch_create,
                          owner: device.user,
                          params: { count: checkins.ids.count })
    end

    def checkin_create(hash)
      checkin = Checkin.new(hash.slice("lat", "lng", "speed", "altitude", "created_at", "fogged"))
      raise ActiveRecord::Rollback && context.fail! unless valid_hash(checkin)
      checkin.assign_values
      checkin
    end

    def valid_hash(checkin)
      checkin.lat? && checkin.lng? && checkin.lat.abs <= 90 && checkin.lng.abs <= 180
    end
  end
end
