module Users::Checkins
  class UpdateCheckin
    include Interactor

    delegate :params, to: :context

    def call
      checkin = Checkin.find(params[:id])
      if params[:checkin]
        checkin.update(allowed_params)
        checkin.refresh
      else
        switch_fog(checkin)
      end
      context.checkin = checkin
    end

    private

    def switch_fog(checkin)
      checkin.update(fogged: !checkin.fogged)
      return if checkin.device.fogged
      checkin.update_output
      checkin.save
    end

    def allowed_params
      params.require(:checkin).permit(:lat, :lng, :created_at, :device_id, :fogged)
    end
  end
end
