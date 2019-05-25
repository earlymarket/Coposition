module Users
  class DashboardsPresenter
    NUMBER_OF_CITIES = 5
    NUMBER_OF_COUNTRIES = 10
    MONTH_CHECKINS_LIMIT = 200
    MONTH_CHECKINS_SAMPLE = 100
    FLIGHT_ALTITUDE = 8000

    def initialize(user)
      @user = user
    end

    def percent_change
      checkins.percentage_increase("week")
    end

    def most_frequent_areas
      checkins.hash_group_and_count_by(:fogged_city).first(NUMBER_OF_CITIES)
    end

    def most_used_device
      Device.find(device_checkins_count.first.first) unless device_checkins_count.empty?
    end

    def last_countries
      c = checkins.select("DISTINCT ON (checkins.created_at) checkins.*").where(last_countries_sql).first NUMBER_OF_COUNTRIES
      puts c
      c
    end

    def last_countries_no_limits
      checkins.where(last_countries_sql)
    end

    def gon
      # gon converts these using #each_pair into seperate gon variables
      {
        current_user: current_user_info,
        friends: friends,
        device_checkins: device_checkins
      }
    end

    def visited_countries_title(countries = last_countries)
      case count = countries.count
      when 1
        "Last country visited"
      when 0
        "No countries visited"
      else
        "Last #{count} countries visited"
      end
    end

    def weeks_checkins_count
      checkins.where(created_at: 1.week.ago..Time.current).count
    end

    private

    def user_devices
      @user_devices ||= @user.devices
    end

    def device_checkins
      checkins = user_devices.map do |device|
        device.checkins.first.as_json.merge(device: device.name) if device.checkins.exists?
      end
      checkins.compact.sort_by { |checkin| checkin["created_at"] }.reverse
    end

    def checkins
      @checkins ||= @user.checkins
    end

    def device_checkins_count
      checkins.hash_group_and_count_by(:device_id)
    end

    def friends
      @user.friends.map.with_index do |friend, index|
        {
          userinfo: friend.public_info_hash,
          lastCheckin: friend.safe_checkin_info_for(permissible: @user, action: "last")[0],
          pinColor: ApprovalsPresenter::PIN_COLORS.to_a[index % ApprovalsPresenter::PIN_COLORS.size][0]
        }
      end
    end

    def current_user_info
      {
        userinfo: @user.public_info_hash,
        lastCheckin: checkins.first
      }
    end

    def circle_icon
      ActionController::Base.helpers.image_path("circle_border")
    end

    def last_countries_sql
      "created_at IN(SELECT MAX(created_at) FROM checkins INNER JOIN devices ON" \
      " checkins.device_id = devices.id WHERE devices.user_id = #{@user.id}" \
      " AND checkins.created_at <= current_timestamp" \
      " AND (checkins.altitude != 0 OR checkins.altitude IS NULL)" \
      " AND (checkins.altitude <= #{FLIGHT_ALTITUDE} OR checkins.altitude IS NULL)" \
      " GROUP BY country_code)"
    end
  end
end
