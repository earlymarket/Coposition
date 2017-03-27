class Users::FriendsController < ApplicationController
  before_action :friends?
  before_action :correct_url_user?

  def show
    @presenter = ::Users::FriendsPresenter.new(current_user, params, "show")
    @friend = @presenter.friend
    @devices = @presenter.devices
    gon.push(@presenter.index_gon)
  end

  def show_device
    @presenter = ::Users::FriendsPresenter.new(current_user, params, "show_device")
    if params[:per_page] && params[:page]
      render json: @presenter.show_checkins.as_json
    else
      gon.push(@presenter.show_device_gon)
    end
  end

  private

  def friends?
    friend = User.find(params[:id])
    return if friend.approved?(current_user)
    flash[:notice] = "You are not friends with that user"
    redirect_to user_friends_path(current_user)
  end
end
