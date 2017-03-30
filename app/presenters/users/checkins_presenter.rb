module Users
  class CheckinsPresenter < ApplicationPresenter
    attr_reader :device

    def initialize(user, params, action)
      @user = user
      @params = params
      send action
    end

    def index
      @device = Device.find(@params[:device_id])
      @per_page = [@params[:per_page].to_i, 1000].min
      range = checkins_date_range
      @checkins = range[:from] ? @device.checkins.where(created_at: range[:from]..range[:to]) : @device.checkins
    end

    def json
      {
        checkins: @checkins.paginate(page: @params[:page], per_page: @per_page)
                           .select(:id, :lat, :lng, :created_at, :address, :fogged, :fogged_city, :device_id),
        current_user_id: @user.id,
        total: @checkins.count
      }
    end
  end
end
