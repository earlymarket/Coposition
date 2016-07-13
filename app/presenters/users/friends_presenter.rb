module Users
  class FriendsPresenter
    attr_reader :friend
    attr_reader :devices
    attr_reader :device

    def initialize(user, params, action)
      @user = user
      @friend = User.find(params[:id])
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
      {
        checkins: device_checkins
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
      checkins = checkins.replace_foggable_attributes unless device.can_bypass_fogging?(@user)
      checkins.map(&:public_info)
    end
  end
end
