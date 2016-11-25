module Users
  class FriendsPresenter
    attr_reader :friend
    attr_reader :devices
    attr_reader :device
    attr_reader :show_checkins

    def initialize(user, params, action)
      @user = user
      @friend = User.friendly.find(params[:id])
      @params = params
      send action
    end

    def show
      @devices = @friend.devices.ordered_by_checkins.paginate(page: @params[:page], per_page: 5)
    end

    def show_device
      @device = @friend.devices.find(@params[:device_id])
    end

    def index_gon
      {
        checkins: most_recent_checkins
      }
    end

    def show_device_gon
      checkins = device_checkins
      per_page = checkins.size < 1000 ? checkins.size : 1000
      {
        checkins: checkins.paginate(page: 1, per_page: per_page),
        total: checkins.size
      }
    end

    def show_checkins(params)
      {
        checkins: device_checkins.paginate(page: params[:page], per_page: params[:per_page])
      }
    end

    private

    def most_recent_checkins
      checkins = @devices.map do |device|
        checkins = device.safe_checkin_info_for(permissible: @user)
        checkins.first.as_json.merge(device: device.name) if checkins.present?
      end.compact
      checkins.sort_by { |checkin| checkin['created_at'] }.reverse
    end

    def device_checkins
      device = @friend.devices.find(@params[:device_id])
      checkins = @friend.get_checkins(@user, device)
      device.replace_checkin_attributes(@user, checkins)
    end
  end
end
