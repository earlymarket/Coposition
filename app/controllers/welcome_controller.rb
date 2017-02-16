class WelcomeController < ApplicationController
  def index
    render 'placeholder_users', layout: false if Rails.env == 'production' && (!params[:admin] || !signed_in?)
    # render 'placeholder_users', layout: false
  end

  def devs
    render 'placeholder_devs', layout: false if Rails.env == 'production' && (!params[:admin] || !signed_in?)
    # render 'placeholder_devs', layout: false
  end

  def api
  end

  def help
    gon.userinfo = current_user.public_info_hash if current_user
  end

  def getting_started
  end
end
