class Users::FriendsController < ApplicationController
  before_action :friends?
  before_action :correct_url_user?

  def show
    @friend_show_presenter = ::Users::Friends::FriendsShowPresenter.new(current_user, params)
    gon.push(@friend_show_presenter.gon)
  end

  def show_device
    @device_show_presenter = ::Users::Friends::FriendsShowDevicePresenter.new(current_user, params)
    if params[:per_page] && params[:page]
      render json: @device_show_presenter.checkins.as_json
    else
      gon.push(@device_show_presenter.gon)
    end
  end

  def request_checkin
    RequestCheckin.call(current_user: current_user, id: params[:id])
    redirect_to user_friends_path, notice: "Check-in request sent"
  end

  private

  def friends?
    friend = User.find(params[:id])
    return if friend.approved?(current_user)
    flash[:notice] = "You are not friends with that user"
    redirect_to user_friends_path(current_user)
  end
end
