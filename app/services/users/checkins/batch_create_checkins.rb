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
          checkin = Checkin.new(checkin_hash.slice('lat', 'lng', 'created_at', 'fogged'))
          raise ActiveRecord::Rollback unless checkin.lat && checkin.lng
          checkin.assign_values
          checkin.fogged ? checkin.assign_output_to_fogged : checkin.assign_output_to_unfogged
          checkin.device.notify_subscribers('new_checkin', checkin)
          checkin
        end
        Checkin.import checkins
      end
    end
  end
end
