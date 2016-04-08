class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    if (checkins = current_user.get_user_checkins(nil)).present?
      gon.weeks_checkins = checkins.where(created_at: 1.week.ago..Time.now)
      fogged_area_count = checkins.hash_group_and_count_by(:fogged_area)
      device_checkins_count = checkins.hash_group_and_count_by(:device_id)
      @most_used_device = Device.find(device_checkins_count.first.first)
      @most_frequent_areas = fogged_area_count.first 5
      @week_checkins_count = gon.weeks_checkins.count
      @percent_change = checkins.percentage_increase('week')
    end
  end

end
