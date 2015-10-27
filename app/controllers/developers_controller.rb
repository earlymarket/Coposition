class DevelopersController < ApplicationController

  before_action :authenticate_developer!

  def edit
    @developer = current_developer
  end

end