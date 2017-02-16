class ImportWorker
  include Sidekiq::Worker

  def perform(device, json_file)
    file_array = JSON.parse(json_file)
    Checkin.transaction do
      file_array.drop(1).each do |row|
        attr = row.split(',')
        checkin = Checkin.find_by_id(attr[0]) || Checkin.new
        checkin.assign_attributes(lat: attr[1], lng: attr[2], created_at: attr[3], fogged: attr[11], device_id: device)
        checkin.save!
      end
    end
  end
end
