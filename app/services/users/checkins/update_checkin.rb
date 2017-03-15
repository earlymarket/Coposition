module Users::Checkins
  class UpdateCheckin
    include Interactor

    delegate :params, to: :context

    def call
      context.checkin = Checkin.find(params[:id])
      if params[:checkin]
        context.checkin.update(allowed_params)
        context.checkin.refresh
      else
        switch_fog
      end
    end

    def success?
      @checkin.errors.none?
    end

    private

    def switch_fog
      checkin = context.checkin
      checkin.update(fogged: !checkin.fogged)
      return if checkin.device.fogged
      checkin.update_output
      checkin.save
    end

    def allowed_params
      params.require(:checkin).permit(:lat, :lng, :device_id, :fogged)
    end
  end
end
