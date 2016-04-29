module Users
  class DashboardsPresenter

    attr_reader :most_frequent_areas
    attr_reader :percent_change
    attr_reader :weeks_checkins_count

    def initialize(user)
      # No attr_readers for these values so they're private
      @user = user
      @checkins = @user.checkins

      # These are public
      @most_frequent_areas = fogged_area_count.first(5)
      @percent_change = @checkins.percentage_increase('week')
      @weeks_checkins_count = weeks_checkins.count
    end

    def most_used_device
      Device.find(device_checkins_count.first.first) unless device_checkins_count.empty?
    end

    def gon
      # gon converts these using #each_pair into seperate gon variables
      {
        current_user: current_user_info,
        friends: friends,
        weeks_checkins: weeks_checkins,
        months_checkins: months_checkins
      }
    end

    private
    # Private methods act as a black box. Therefore we don't need to test them.

      def fogged_area_count
        @checkins.hash_group_and_count_by(:fogged_area)
      end

      def device_checkins_count
        @checkins.hash_group_and_count_by(:device_id)
      end

      def friends
        friends = @user.friends.includes(:devices)
        friends.map do |friend|
          {
            userinfo: friend.public_info_hash,
            lastCheckin: friend.get_user_checkins_for(@user).first
          }
        end
      end

      def weeks_checkins
        @checkins.where(created_at: 1.week.ago..Time.now)
      end

      def months_checkins
        @checkins.where(created_at: 1.month.ago..Time.now)
      end

      def current_user_info
        {
          userinfo: @user.public_info,
          lastCheckin: @user.checkins.first
        }
      end

  end
end
