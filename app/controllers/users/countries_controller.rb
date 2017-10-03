class Users::CountriesController < ApplicationController
  before_action :authenticate_user!
  helper_method :visits_by_year

  def index
  end

  private

  def visits
    @visits = CountriesVisitPeriodQuery.new(user: current_user)
    @visits = if params[:last_visited]
      @visits.last_visited
    else
      @visits.full_history
    end
  end

  def visits_by_year
    @visits_by_year = visits.group_by { |visit| visit["max_date"].to_date.year }
  end
end

