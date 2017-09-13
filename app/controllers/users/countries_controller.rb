class Users::CountriesController < ApplicationController
  before_action :authenticate_user!
  helper_method :countries

  def index
  end

  private

  def countries
    @countries = CountriesVisitPeriodQuery.new(user: current_user)
    @countries = if params[:last_visited]
      @countries.last_visited
    else
      @countries.full_history
    end
  end
end

