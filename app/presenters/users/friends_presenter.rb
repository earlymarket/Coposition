module Users
  class FriendsPresenter
    attr_reader :friend
    attr_reader :devices

    def initialize(user, params, action)
      @user = user
      @friend = User.find(params[:id])
      @params = params
      send action if action.present?
    end

    def show
      @devices = @friend.devices.ordered_by_checkins.paginate(page: @params[:page], per_page: 5)
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
      @devices.map do |device|
        checkins = device.safe_checkin_info_for(permissible: @user)
        checkins.first.as_json.merge(device: device.name) if checkins.present?
      end.compact
    end

    def device_checkins
      device = @friend.devices.find(@params[:device_id])
      checkins = @friend.get_checkins(@user, device)
      checkins = checkins.replace_foggable_attributes unless device.can_bypass_fogging?(@user)
      checkins.map(&:public_info)
    end
  end
end
