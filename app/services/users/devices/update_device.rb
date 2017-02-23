module Users::Devices
  class UpdateDevice
    attr_reader :device

    def initialize(params)
      @params = params
      @device = Device.find(params[:id])
    end

    def update_device
      if @params[:delayed]
        update_delay(@params[:delayed])
      else
        @device.update(allowed_params)
      end
      @device
    end

    def notice
      if @params[:delayed]
        humanize_delay
      elsif allowed_params[:published]
        "Location sharing is #{boolean_to_state(@device.published)}."
      elsif allowed_params[:cloaked]
        "Device cloaking is #{boolean_to_state(@device.cloaked)}."
      elsif allowed_params[:icon]
        'Device icon updated'
      elsif allowed_params[:fogged]
        "Location fogging is #{boolean_to_state(@device.fogged)}."
      end
    end

    private

    def boolean_to_state(boolean)
      boolean ? 'on' : 'off'
    end

    def update_delay(mins)
      mins.to_i.zero? ? @device.update(delayed: nil) : @device.update(delayed: mins)
    end

    def humanize_delay
      if @device.delayed.nil?
        "#{@device.name} is not delayed."
      else
        "#{@device.name} delayed by #{humanize_minutes(@device.delayed)}."
      end
    end

    def humanize_minutes(minutes)
      if minutes < 60
        "#{minutes} #{'minute'.pluralize(minutes)}."
      elsif minutes < 1440
        hours = minutes / 60
        minutes = minutes % 60
        "#{hours} #{'hour'.pluralize(hours)} and #{minutes} #{'minutes'.pluralize(minutes)}."
      else
        days = minutes / 1440
        "#{days} #{'day'.pluralize(days)}."
      end
    end

    def allowed_params
      @params.require(:device).permit(:name, :uuid, :icon, :fogged, :delayed, :published, :cloaked, :alias)
    end
  end
end
