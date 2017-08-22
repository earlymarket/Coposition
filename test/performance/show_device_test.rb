require "benchmark_helper"

class Users::DevicesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
end

class ShowDeviceTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  test "show_device" do
    dev = Developer.first
    user = dev.users.first
    device = user.devices.first

    get "/users/#{user.id}/devices/#{device.id}", as: "json"
  end
end
