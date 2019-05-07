module Users::Checkins
  class ImportCheckins
    include Interactor
    delegate :params, to: :context

    def call
      if file && valid_file?
        device.update(csv: File.open(path, "r"))
        create_activity
        ImportWorker.perform_async(device.id)
      else
        context.fail!(error: error)
      end
    end

    private

    def create_activity
      CreateActivity.call(
        entity: device,
        action: :import,
        owner: device.user,
        params: { count: CSV.read(path).length }
      )
    end

    def file
      @file ||= params[:file]
    end

    def path
      @path ||= file.path
    end

    def device
      @device ||= Device.find(params[:device_id])
    end

    def valid_file?
      return false unless file.content_type == "text/csv"
      CSV.foreach(path, headers: true) do |csv|
        return csv.headers.sort == Checkin.column_names.sort
      end
    end

    def error
      return "You must choose a CSV file to upload" unless file
      "Invalid file format"
    end
  end
end
