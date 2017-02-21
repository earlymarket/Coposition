class ImportWorker
  include Sidekiq::Worker

  def perform(device, path)
    Checkin.transaction do
      CSV.foreach(path, headers: true) do |row|
        checkin_create_or_update_from_row!(row, device)
      end
    end
  end

  def checkin_create_or_update_from_row!(row, device)
    checkin = Checkin.unscope(:order).find_by_id(row['id']) || Checkin.new
    checkin.attributes = attributes_from_row(row)
    checkin.device_id = device
    checkin.save!
  end

  def attributes_from_row(row)
    row.to_hash.slice('lat', 'lng', 'created_at', 'fogged')
  end
end