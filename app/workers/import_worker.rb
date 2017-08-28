class ImportWorker
  include Sidekiq::Worker

  def perform(device_id)
    device = Device.find(device_id)
    resource = Cloudinary::Api.resource(device.csv.public_id, resource_type: "raw")
    download = Cloudinary::Downloader.download(resource["secure_url"])
    Checkin.transaction do
      CSV.parse(download, headers: true) do |row|
        checkin_create_or_update_from_row!(row, device_id)
      end
    end
    Cloudinary::Uploader.destroy(device.csv.public_id, resource_type: "raw")
  end

  def checkin_create_or_update_from_row!(row, device_id)
    checkin = Checkin.unscope(:order).find_by(id: row["id"]) || Checkin.new
    checkin.attributes = attributes_from_row(row)
    checkin.device_id = device_id
    checkin.save!
  end

  def attributes_from_row(row)
    row.to_hash.slice("lat", "lng", "speed", "altitude", "created_at", "fogged")
  end
end
