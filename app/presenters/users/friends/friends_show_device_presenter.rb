module Users::Friends
  class FriendsShowDevicePresenter < ApplicationPresenter
    attr_reader :friend
    attr_reader :device
    attr_reader :date_range

    def initialize(user, params)
      @user = user
      @friend = User.find(params[:id])
      @params = params
      @device = friend.devices.where(cloaked: false).find(@params[:device_id])
    end

    def gon
      checkins = device_checkins
      {
        checkins: checkins.paginate(page: 1, per_page: 1000),
        total: checkins.size
      }
    end

    def checkins
      {
        checkins: device_checkins.paginate(page: @params[:page], per_page: @params[:per_page])
      }
    end

    def form_for
      friend
    end

    def form_path
      show_device_user_friend_path(@user.url_id, friend, device_id: device.id)
    end

    def form_range_filter(text, from)
      link_to(text, show_device_user_friend_path(@user.url_id, friend,
        device_id: device, from: from, to: Time.zone.today), method: :get)
    end

    private

    def device_checkins
      @date_range = checkins_date_range
      checkins = device.permitted_history_for(@user)
      checkins = checkins.where(created_at: date_range[:from]..date_range[:to]) if date_range[:from]
      device.replace_checkin_attributes(checkins, @user)
    end
  end
end
