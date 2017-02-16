class ImportWorker
  include Sidekiq::Worker

  def perform(device, json_file)
    Checkin.transaction do
      file_array(json_file).drop(1).each do |row|
        checkin_create_or_update_from_row!(row, device)
      end
    end
  end

  def file_array(json_file)
    JSON.parse(json_file)
  end

  def checkin_create_or_update_from_row!(row, device)
    attrs = attributes_from_row(row, device)
    checkin = Checkin.find_by_id(attrs.delete(:id)) || Checkin.new
    checkin.assign_attributes(attrs)
    checkin.save!
  end

  def attributes_from_row(row, device)
    attr = row.split(",")
    { id: attr[0], lat: attr[1], lng: attr[2], created_at: attr[3], fogged: attr[11], device_id: device }
  end
end
