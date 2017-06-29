require "benchmark_helper"

class Users::ApprovalsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
end

class ShowFriendsTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  test "show_friends" do
    dev = Developer.first
    user = dev.users.first

    get "/users/#{user.id}/friends", as: "json"
  end
end
