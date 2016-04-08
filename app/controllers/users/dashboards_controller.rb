class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    if (checkins = current_user.get_user_checkins(nil)).present?
      gon.weeks_checkins = checkins.where(created_at: 1.week.ago..Time.now)
      fogged_area_count = checkins.hash_group_and_count_by(:fogged_area)
      device_checkins_count = checkins.hash_group_and_count_by(:device_id)
      @most_used_device = Device.find(device_checkins_count.first.first)
      @most_frequent = fogged_area_count.first 5
      @week_checkins_count = gon.weeks_checkins.count
      last_weeks_checkins_count = checkins.where(created_at: 2.weeks.ago..1.week.ago).count
      if @week_checkins_count > 0 && last_weeks_checkins_count > 0
        @percent_change = (((@week_checkins_count.to_f/last_weeks_checkins_count.to_f)-1)*100).round(2)
      end
    end
  end

end
