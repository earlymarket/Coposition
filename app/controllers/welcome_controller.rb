class WelcomeController < ApplicationController
  def index
    render "placeholder_users"
  end

  def devs
    render "placeholder_devs"
  end

  def api
  end

  def help
    gon.userinfo = current_user.public_info_hash if current_user
  end

  def getting_started
  end

  def terms
  end
end
