class ImportWorker
  include Sidekiq::Worker

  def perform(device_id, path)
    Checkin.transaction do
      CSV.foreach(path, headers: true) do |row|
        checkin_create_or_update_from_row!(row, device_id)
      end
    end
  end

  def checkin_create_or_update_from_row!(row, device_id)
    checkin = Checkin.unscope(:order).find_by(id: row["id"]) || Checkin.new
    checkin.attributes = attributes_from_row(row)
    checkin.device_id = device_id
    checkin.save!
  end

  def attributes_from_row(row)
    row.to_hash.slice("lat", "lng", "created_at", "fogged")
  end
end
