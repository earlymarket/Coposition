class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    checkins = current_user.devices.includes(:checkins).each.map { |device| device.checkins }
    checkins.flatten!
    fogged_area_count = checkins.select(&:fogged_area).group_by(&:fogged_area).inject({}) do |hash, (area,count)|
      hash[area] = count.length
      hash
    end
    device_checkins_count = checkins.select(&:device_id).group_by(&:device_id).inject({}) do |hash, (device,count)|
      hash[device] = count.length
      hash
    end
    @most_used_device = Device.find(Hash[device_checkins_count.sort_by{ |_, v| -v}].first.first)
    @most_frequent = Hash[fogged_area_count.sort_by{ |_, v| -v}].first 5
  end

end
