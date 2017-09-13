ActiveAdmin.register_page "Device Settings" do
  BOOLEAN_HEADERS = %w(Flag On Off).freeze
  INTERVAL_TYPES = %w(distance time).freeze
  TIME_INTERVALS = %w(10 30 60 300 1800 3600 21600 86400).freeze
  DISTANCE_INTERVALS = %w(50 100 200 500 1000).freeze
  BATTERY_SAVING = %w(false true low high).freeze
  DELAY = [0, 5, 10, 30, 60, 360, 1440].freeze

  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:booleans] = [
        { name: "Fogged", values: fogged_stats },
        { name: "Cloaked", values: cloaked_stats },
        { name: "Auto", values: active_stats },
        { name: "Smart", values: smart_stats }
      ]

      params[:interval_type] = interval_stats
      params[:time_interval] = time_stats
      params[:distance_interval] = distance_stats
      params[:battery_saver] = battery_stats
      params[:delay] = delay_stats
    end

    private

    def fogged_stats
      return { on: "n/a", off: "n/a" } if Device.count.zero?

      {
        on: '%.2f %' % (num = Device.where(fogged: true).count.to_f * 100 / Device.count),
        off: '%.2f %' % (100 - num)
      }
    end

    def cloaked_stats
      return { on: "n/a", off: "n/a" } if Device.count.zero?

      {
        on: '%.2f %' % (num = Device.where(cloaked: true).count.to_f * 100 / Device.count),
        off: '%.2f %' % (100 - num)
      }
    end

    def active_stats
      return { on: "n/a", off: "n/a" } if copo_mobile_devices.count.zero?

      {
        on: '%.2f %' % (
          num = copo_mobile_devices { |dev| dev.config.custom["active"].to_s == "true" }
            .size.to_f * 100 / copo_mobile_devices.count
        ),
        off: '%.2f %' % (100 - num)
      }
    end

    def smart_stats
      devices = copo_mobile_devices { |dev| !dev.config.custom["smartInterval"].nil? }
      return { on: "n/a", off: "n/a" } if devices.count.zero?

      {
        on: '%.2f %' % (
          num = devices
            .select { |dev| dev.config.custom["smartInterval"].to_s == "true" }
            .size.to_f * 100 / devices.count
        ),
        off: '%.2f %' % (100 - num)
      }
    end

    def interval_stats
      devices = copo_mobile_devices { |dev| !dev.config.custom["intervalType"].nil? }
      return ["n/a"] * INTERVAL_TYPES.size if devices.size.zero?

      INTERVAL_TYPES.map do |type|
        '%.2f %' % (
          devices
            .select { |dev| dev.config.custom["intervalType"].to_s == type }
            .size.to_f * 100 / devices.size
        )
      end
    end

    def time_stats
      devices = copo_mobile_devices { |dev| !dev.config.custom["timeInterval"].nil? }
      return ["n/a"] * TIME_INTERVALS.size if devices.size.zero?

      TIME_INTERVALS.map do |interval|
        '%.2f %' % (
          devices
            .select { |dev| dev.config.custom["timeInterval"].to_i == interval.to_i }
            .size.to_f * 100 / devices.size
        )
      end
    end

    def distance_stats
      devices = copo_mobile_devices { |dev| !dev.config.custom["distanceInterval"].nil? }
      return ["n/a"] * DISTANCE_INTERVALS.size if devices.size.zero?

      DISTANCE_INTERVALS.map do |interval|
        '%.2f %' % (
          devices
            .select { |dev| dev.config.custom["distanceInterval"].to_i == interval.to_i }
            .size.to_f * 100 / devices.size
        )
      end
    end

    def battery_stats
      devices = copo_mobile_devices { |dev| !dev.config.custom["batterySaving"].nil? }
      return ["n/a"] * BATTERY_SAVING.size if devices.size.zero?

      BATTERY_SAVING.map do |battery|
        '%.2f %' % (
          devices
            .select { |dev| dev.config.custom["batterySaving"].to_s == battery }
            .size.to_f * 100 / devices.size
        )
      end
    end

    def delay_stats
      return ["n/a"] * DELAY.size if Device.count.zero?

      DELAY.map do |delay|
        '%.2f %' % (
          Device.where(delayed: delay).count.to_f * 100 / Device.count
        )
      end
    end

    def copo_mobile_devices
      @copo_mobile_devices ||= Device.includes(:config)
        .select { |dev| dev.config && dev.config.custom && !dev.config.custom["active"].nil? }

      block_given? ? @copo_mobile_devices.select { |dev| yield dev } : @copo_mobile_devices
    end
  end
end
