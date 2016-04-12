module Users
  class DashboardPresenter

    attr_reader :most_frequent_areas
    attr_reader :percent_change
    attr_reader :most_used_device
    attr_reader :weeks_checkins_count
    attr_reader :weeks_checkins

    def initialize(checkins)
      @checkins = checkins
      @most_frequent_areas = fogged_area_count.first(5)
      @percent_change = checkins.percentage_increase('week')
      @most_used_device = Device.find(device_checkins_count.first.first)
      @weeks_checkins_count = weeks_checkins.count
    end

    def weeks_checkins
      @checkins.where(created_at: 1.week.ago..Time.now)
    end

    private

      def fogged_area_count
        @checkins.hash_group_and_count_by(:fogged_area)
      end

      def device_checkins_count
        @checkins.hash_group_and_count_by(:device_id)
      end

  end
end
