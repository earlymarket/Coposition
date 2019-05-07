require "benchmark_helper"

class Users::CheckinsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
end

class CreateCheckinTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  test "checkin_create" do
    dev = Developer.first
    user = dev.users.first
    device = user.devices.first
    checkin = device.checkins.first

    post "/users/#{user.id}/devices/#{device.id}/checkins",
      params: { checkin: { lat: checkin.lat, lng: checkin.lng } },
      as: "json"
  end

  test "fogged_checkin_create" do
    dev = Developer.first
    user = dev.users.first
    device = user.devices.first
    checkin = device.checkins.first

    post "/users/#{user.id}/devices/#{device.id}/checkins",
      params: { checkin: { lat: checkin.lat, lng: checkin.lng, fogged: true } },
      as: "json"
  end
end
