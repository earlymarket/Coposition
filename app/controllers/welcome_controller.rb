class WelcomeController < ApplicationController
  def index
    render 'placeholder', layout: false if Rails.env == 'production' && !params[:admin] && !signed_in?
  end

  def api
  end

  def help
    gon.userinfo = current_user.public_info_hash if current_user
  end

  def getting_started
  end
end
