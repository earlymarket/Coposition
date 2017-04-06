module Users
  class DashboardsPresenter
    attr_reader :most_frequent_areas
    attr_reader :percent_change
    attr_reader :weeks_checkins_count
    attr_reader :last_countries_loaded
    attr_reader :most_used

    def initialize(user)
      # No attr_readers for these values so they're private
      @user = user
      @checkins = @user.checkins

      # These are public
      @most_frequent_areas = fogged_city_count.first(5)
      @percent_change = @checkins.percentage_increase('week')
      @weeks_checkins_count = weeks_checkins.count
      @most_used = most_used_device
      @last_countries_loaded = last_countries
    end

    def most_used_device
      Device.find(device_checkins_count.first.first) unless device_checkins_count.empty?
    end

    def last_countries
      last_countries_sql = "created_at IN(SELECT MAX(created_at) FROM checkins INNER JOIN devices ON"\
        " checkins.device_id = devices.id WHERE devices.user_id = #{@user.id} GROUP BY country_code)"
      @checkins.where(last_countries_sql).first 10
    end

    def gon
      # gon converts these using #each_pair into seperate gon variables
      {
        current_user: current_user_info,
        friends: friends,
        months_checkins: months_checkins
      }
    end

    def visited_countries_title
      case count = last_countries_loaded.count
      when 1
        "Last Country Visited"
      when 0
        "No Countries Visited"
      else
        "Last #{count} Countries Visited"
      end
    end

    private

    def fogged_city_count
      @checkins.hash_group_and_count_by(:fogged_city)
    end

    def device_checkins_count
      @checkins.hash_group_and_count_by(:device_id)
    end

    def friends
      @user.friends.map do |friend|
        {
          userinfo: friend.public_info_hash,
          lastCheckin: friend.safe_checkin_info_for(permissible: @user, action: 'last')[0]
        }
      end
    end

    def weeks_checkins
      @checkins.where(created_at: 1.week.ago..Time.now)
    end

    def months_checkins
      @checkins.where(created_at: 1.month.ago..Time.now).limit(200).sample(100)
    end

    def current_user_info
      {
        userinfo: @user.public_info_hash,
        lastCheckin: @checkins.first
      }
    end
  end
end
