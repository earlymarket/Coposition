class WelcomeController < ApplicationController

  def index
  	render "placeholder", layout: false if (Rails.env == "production" && !params[:admin] && !signed_in?)
  end

  def api
    render html: ReadmeInterpreter.new("README.md").create_api_page
  end

end
