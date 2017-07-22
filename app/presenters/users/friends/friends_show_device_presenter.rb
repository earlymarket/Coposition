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

      @date_range = first_load ? first_load_range : checkins_date_range
    end

    def gon
      checkins = device_checkins
      {
        checkins: ActiveRecord::Base.connection.execute(checkins.to_sql).to_a,
        first_load: first_load,
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

    def first_load
      @first_load ||= params[:first_load]
    end

    def first_load_range
      return { from: nil, to: nil } if (checkins = device.checkins.limit(5000)).size.zero?
      { from: checkins.last.created_at.beginning_of_day, to: checkins.first.created_at.end_of_day }
    end

    private

    def device_checkins
      checkins = device.permitted_history_for(@user)
      if first_load
        checkins = checkins.limit(5000)
      elsif date_range[:from]
        checkins = checkins.where(created_at: date_range[:from]..date_range[:to])
      end
      device.replace_checkin_attributes(checkins, @user)
    end
  end
end
