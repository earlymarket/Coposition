class Users::CountriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @countries = CountriesVisitedQuery.new(user: current_user).with_names
  end
end

