module Users::Devices
  class UpdateDevice
    include Interactor

    delegate :params, to: :context

    def call
      if params[:delayed]
        device.update(delayed: params[:delayed])
      else
        device.update(allowed_params)
      end
      check_for_errors
      create_activity
      context.device = device
      context.notice = notice
    end

    private

    def device
      @device ||= Device.find(params[:id])
    end

    def notice
      if params[:delayed]
        humanize_delay
      elsif !allowed_params[:published].nil?
        "Location sharing is #{boolean_to_state(device.published)}."
      elsif !allowed_params[:cloaked].nil?
        "Device cloaking is #{boolean_to_state(device.cloaked)}."
      elsif allowed_params[:icon]
        "Device icon updated"
      elsif !allowed_params[:fogged].nil?
        "Location fogging is #{boolean_to_state(device.fogged)}."
      end
    end

    def check_for_errors
      context.fail!(error: device.errors.messages) if device.errors.any?
    end

    def create_activity
      CreateActivity.call(entity: device,
                          action: :update,
                          owner: device.user,
                          params: params[:delayed] ? { delayed: params[:delayed] } : allowed_params.to_h)
    end

    def boolean_to_state(boolean)
      boolean ? "on" : "off"
    end

    def humanize_delay
      if device.delayed.zero?
        "#{device.name} is not delayed."
      else
        "#{device.name} delayed by #{humanize_minutes(device.delayed)}."
      end
    end

    def humanize_minutes(minutes)
      if minutes < 60
        "#{minutes} #{'minute'.pluralize(minutes)}"
      elsif minutes < 1440
        hours = minutes / 60
        minutes = minutes % 60
        "#{hours} #{'hour'.pluralize(hours)} and #{minutes} #{'minutes'.pluralize(minutes)}"
      else
        days = minutes / 1440
        "#{days} #{'day'.pluralize(days)}"
      end
    end

    def allowed_params
      params.require(:device).permit(:name, :uuid, :icon, :fogged, :delayed, :published, :cloaked, :alias)
    end
  end
end
