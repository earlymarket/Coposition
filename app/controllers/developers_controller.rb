class DevelopersController < ApplicationController

  before_action :authenticate_developer!

  def edit
    @developer = current_developer
  end

  def update
    current_developer.update(allowed_params)
    redirect_to developers_console_path
  end

  def allowed_params
    params.require(:developer).permit([:company_name, :logo, :redirect_url])
  end

end