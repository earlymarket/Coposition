class Users::FriendsController < ApplicationController
  before_action :friends?
  before_action :correct_url_user?

  def show
    @presenter = ::Users::Friends::FriendsShowPresenter.new(current_user, params)
    @devices = @presenter.devices
    gon.push(@presenter.gon)
  end

  def show_device
    @presenter = ::Users::Friends::FriendsShowDevicePresenter.new(current_user, params)
    if params[:per_page] && params[:page]
      render json: @presenter.checkins.as_json
    else
      gon.push(@presenter.gon)
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
