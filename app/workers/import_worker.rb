class ImportWorker
  include Sidekiq::Worker

  def perform(device_id)
    device = Device.find device_id
    resource_info = Cloudinary::Api.resource(device.csv.public_id, resource_type: 'raw')
    csv_file = Cloudinary::Downloader.download(resource_info['secure_url'])
    Checkin.transaction do
      CSV.parse(csv_file, headers: true) do |row|
        checkin = Checkin.find_by_id(row['id']) || Checkin.new
        checkin.attributes = row.to_hash.slice('lat', 'lng', 'created_at', 'fogged')
        checkin.device_id = device.id
        checkin.save!
      end
    end
    Cloudinary::Uploader.destroy(@device.csv.public_id, resource_type: 'raw')
    @device.update csv: nil
  end
end
