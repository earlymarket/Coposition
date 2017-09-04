class Users::CountriesController < ApplicationController
  before_action :authenticate_user!
  helper_method :countries_presenter

  def index
  end

  private

  def countries_presenter
    @countries_presenter ||= ::Users::DashboardsPresenter.new(current_user)
  end
end

