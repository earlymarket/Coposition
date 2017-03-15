module Users::Checkins
  class UpdateCheckin
    include Interactor

    delegate :params, to: :context

    def call
      checkin = Checkin.find(params[:id])
      if params[:checkin]
        checkin.update(allowed_params)
        checkin.refresh
        context.checkin = checkin
      else
        switch_fog(checkin)
      end
      context.fail! unless checkin.errors.none?
    end

    private

    def switch_fog(checkin)
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
