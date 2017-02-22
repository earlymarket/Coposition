module Users::Checkins
  class UpdateCheckin
    attr_reader :checkin

    def initialize(params)
      @checkin = Checkin.find(params[:id])
      @params = params
    end

    def success
      if @params[:checkin]
        @checkin.update(allowed_params)
        @checkin.refresh
        return render status: 200, json: @checkin unless @checkin.errors.any?
        render status: 400, json: @checkin.errors.messages
      else
        switch_fog
      end
    end

    def errors
    end

    private

    def switch_fog
      @checkin.update(fogged: !@checkin.fogged)
      return if @checkin.device.fogged
      @checkin.update_output
      @checkin.save
    end
  end
end
