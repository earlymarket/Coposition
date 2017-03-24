module Users::Checkins
  class ImportCheckins
    include Interactor
    delegate :params, to: :context

    def call
      if file && valid_file?
        ImportWorker.perform_async(device.id, file.path)
      else
        context.fail!(error: error)
      end
    end

    private

    def file
      @file ||= params[:file]
    end

    def device
      @device ||= Device.find(params[:device_id])
    end

    def valid_file?
      CSV.foreach(file.path, headers: true) do |csv|
        return csv.headers == Checkin.column_names
      end
    end

    def error
      return "You must choose a CSV file to upload" unless file
      "Invalid CSV file format"
    end
  end
end
