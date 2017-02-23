module Users::Checkins
  class UpdateCheckin
    attr_reader :checkin

    def initialize(params)
      @checkin = Checkin.find(params[:id])
      @params = params
      if @params[:checkin]
        @checkin.update(allowed_params)
        @checkin.refresh
      else
        switch_fog
      end
    end

    def success?
      @checkin.errors.none?
    end

    private

    def switch_fog
      @checkin.update(fogged: !@checkin.fogged)
      return if @checkin.device.fogged
      @checkin.update_output
      @checkin.save
    end

    def allowed_params
      @params.require(:checkin).permit(:lat, :lng, :device_id, :fogged)
    end
  end
end
