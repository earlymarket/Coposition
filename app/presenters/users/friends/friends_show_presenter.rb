module Users::Friends
  class FriendsShowPresenter < ApplicationPresenter
    attr_reader :friend
    attr_reader :devices

    def initialize(user, params)
      @user = user
      @friend = User.find(params[:id])
      @devices = friend.devices.where(cloaked: false).ordered_by_checkins.paginate(page: params[:page], per_page: 5)
    end

    def gon
      {
        checkins: most_recent_checkins
      }
    end

    private

    def most_recent_checkins
      checkins =
        devices.map do |device|
          safe_checkins = device.safe_checkin_info_for(permissible: @user)
          safe_checkins.first.as_json.merge(device: device.name) if safe_checkins.present?
        end
      checkins.compact.sort_by { |checkin| checkin["created_at"] }.reverse
    end
  end
end
