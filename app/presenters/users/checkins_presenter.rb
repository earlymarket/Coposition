module Users
  class CheckinsPresenter < ApplicationPresenter
    attr_reader :user

    def initialize(user, params)
      @user = user
      @params = params
    end

    def json
      {
        checkins: checkins
          .paginate(page: @params[:page], per_page: per_page)
          .select(:id, :lat, :lng, :created_at, :address, :fogged, :fogged_city, :device_id),
        current_user_id: user.id,
        total: checkins.count
      }
    end

    private

    def per_page
      @per_page ||= [@params[:per_page].to_i, 5000].min
    end

    def checkins
      range = checkins_date_range
      checkins = device_ids ? user.checkins.where(device_id: device_ids) : user.checkins
      range[:from] ? checkins.where(created_at: range[:from]..range[:to]) : checkins
    end

    def device_ids
      params[:device_id]&.include?(",") ? params[:device_id].split(",") : params[:device_id]
    end
  end
end
