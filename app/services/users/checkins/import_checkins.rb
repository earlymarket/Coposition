module Users::Checkins
  class ImportCheckins

    def initialize(params)
    	@file = params[:file]
    	@device = Device.find(params[:device_id])
    end

    def success?
    	if @file && valid_file?
        @device.csv = File.open(@file.path, "r")
        @device.save
    	  import
    	  true
    	end
    end

    def valid_file?
      CSV.foreach(@file.path, headers: true) do |csv|
        return csv.headers == Checkin.column_names
      end
    end

    def import
      resource = Cloudinary::Api.resource(@device.csv.public_id, {resource_type: 'raw'})
      download = Cloudinary::Downloader.download(resource['secure_url'])
      Checkin.transaction do
        CSV.parse(download, headers: true) do |row|
          checkin = Checkin.find_by_id(row['id']) || Checkin.new
          checkin.attributes = row.to_hash.slice('lat', 'lng', 'created_at', 'fogged')
          checkin.device_id = @device.id
          checkin.save!
        end
      end
    end
    handle_asynchronously :import

    def error
      return 'You must choose a CSV file to upload' unless @file
      'Invalid CSV file format'
    end
  end
end
