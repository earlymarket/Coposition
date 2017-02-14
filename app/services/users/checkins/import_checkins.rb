module Users::Checkins
  class ImportCheckins

    def initialize(params)
    	@file = params[:file]
    	@device_id = params[:device_id]
    end

    def success?
    	if @file && valid_file?
        device = Device.find(@device_id)
        device.csv = File.open(@file.path, "r")
        device.save
    	  Checkin.import_file(@device_id)
    	  true
    	end
    end

    def valid_file?
      CSV.foreach(@file.path, headers: true) do |csv|
        return csv.headers == Checkin.column_names
      end
    end

    def error
      return 'You must choose a CSV file to upload' unless @file
      'Invalid CSV file format'
    end
  end
end
