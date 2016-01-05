class Users::CheckinsController < ApplicationController

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
  end

end