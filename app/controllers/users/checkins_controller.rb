class Users::CheckinsController < ApplicationController

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
    @checkin.get_data
    render @checkin
  end

end