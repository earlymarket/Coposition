class ActivitiesController < ApplicationController
  before_action :authenticate_admin!

  def index
    @activities_presenter = ActivitiesPresenter.new(params)
    gon.push(@activities_presenter.gon)
  end
end
