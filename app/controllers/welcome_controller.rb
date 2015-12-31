class WelcomeController < ApplicationController

  def index
  	render "placeholder", layout: false if (Rails.env == "production" && !params[:admin] && !signed_in?)
  end

  def api
    # @html = ReadmeInterpreter.new("README.md").create_api_page.html_safe
  end

end
