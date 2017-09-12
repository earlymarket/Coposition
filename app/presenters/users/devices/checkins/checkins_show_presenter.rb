module Users::Devices::Checkins
  class CheckinsShowPresenter < ApplicationPresenter
    attr_reader :user
    attr_reader :device
    attr_reader :checkin

    def initialize(user, params)
      @user = user
      @params = params
      @checkin = Checkin.find(params[:id])
      @checkin.reverse_geocode!
      @device = checkin.device
    end

    def show_gon
      {
        checkin: checkin,
        device: device,
        user: user.public_info_hash
      }
    end
  end
end
