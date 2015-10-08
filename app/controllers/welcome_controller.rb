class WelcomeController < ApplicationController

  def index
  	render "placeholder", layout: false #if Rails.env == "production"
  end

end
