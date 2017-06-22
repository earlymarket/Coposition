ActiveAdmin.register_page "Device Settings" do
  BOOLEAN_HEADERS = %w(Flag On Off).freeze
  INTERVAL_TYPES = %w(distance time).freeze
  TIME_INTERVALS = [10, 30, 60, 300, 18000, 36000, 216000, 5184000].freeze
  DISTANCE_INTERVALS = [50, 100, 200, 500, 1000].freeze
  BATTERY_SAVING = %w(off low high).freeze
  DELAY = [nil, 300, 18000, 36000, 216000, 5184000].freeze

  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:booleans] = [
        { name: "Fogged", values: fogged_stats },
        { name: "Cloaked", values: cloaked_stats },
        { name: "Active", values: active_stats }
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
        on: '%.2f %' % (num = Device.where(fogged: true).count * 100 / Device.count),
        off: '%.2f %' % (100 - num)
      }
    end

    def cloaked_stats
      return { on: "n/a", off: "n/a" } if Device.count.zero?

      {
        on: '%.2f %' % (num = Device.where(cloaked: true).count * 100 / Device.count),
        off: '%.2f %' % (100 - num)
      }
    end

    def active_stats
      return { on: "n/a", off: "n/a" } if Device.count.zero?

      {
        on: '%.2f %' % (num = Device.automated.size * 100 / Device.count),
        off: '%.2f %' % (100 - num)
      }
    end

    def interval_stats
      return ["n/a"] * INTERVAL_TYPES.size if automated_devices.size.zero?

      INTERVAL_TYPES.map do |type|
        '%.2f' % (
          automated_devices
            .select { |dev| dev.config && dev.config.custom && dev.config.custom["intervalType"] == type }
            .size / automated_devices.size
        )
      end
    end

    def time_stats
      return ["n/a"] * TIME_INTERVALS.size if automated_devices.size.zero?

      TIME_INTERVALS.map do |interval|
        '%.2f %' % (
          automated_devices
            .select { |dev| dev.config && dev.config.custom && dev.config.custom["timeInterval"] == interval }
            .size * 100 / automated_devices.size
        )
      end
    end

    def distance_stats
      return ["n/a"] * DISTANCE_INTERVALS.size if automated_devices.size.zero?

      DISTANCE_INTERVALS.map do |interval|
        '%.2f %' % (
          automated_devices
            .select { |dev| dev.config && dev.config.custom && dev.config.custom["distanceInterval"] == interval }
            .size * 100 / automated_devices.size
        )
      end
    end

    def battery_stats
      return ["n/a"] * BATTERY_SAVING.size if Device.count.zero?

      BATTERY_SAVING.map do |battery|
        '%.2f %' % (
          Device
            .select { |dev| dev.config && dev.config.custom && dev.config.custom["batterySaving"] == battery }
            .size * 100 / Device.count
        )
      end
    end

    def delay_stats
      return ["n/a"] * DELAY.size if Device.count.zero?

      DELAY.map do |delay|
        '%.2f %' % (
          Device.where(delayed: delay).count * 100 / Device.count
        )
      end
    end

    def automated_devices
      @automated ||= Device.automated
    end
  end
end
