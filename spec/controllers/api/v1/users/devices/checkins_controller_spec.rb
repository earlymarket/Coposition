require 'rails_helper'

RSpec.describe Api::V1::Users::Devices::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros

  describe "endpoint" do

    before do
      # Simulating all city records where name == Denham
      @cities = create_denhams
      @developer = FactoryGirl::create :developer
      @user = FactoryGirl::create :user
      @device = FactoryGirl::create :device
      @device.user = @user
      @device.save!
      @checkin = FactoryGirl::build :checkin
      @checkin.lat = 51.588330
      @checkin.lng = -0.513069
      @checkin.uuid = @device.uuid
      @checkin.save!
      request.headers["X-Api-Key"] = @developer.api_key
      @developer.request_approval_from(@user)
      @user.approve_developer(@developer)
    end


    it "should fetch the last reported location" do
      get :last, {
        user_id: @user.id,
        device_id: @device.id
      }

      expect(res_hash[:lat]).to be_within(0.00001).of(@checkin.lat)
    end

    it "should fetch the last reported location's address in full by default" do
      get :last, {
        user_id: @user.id,
        device_id: @device.id,
        type: "address"
      }

      expect(res_hash[:address]).to eq "The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK"
      expect(res_hash[:lat]).to eq @checkin.lat
      expect(res_hash[:lng]).to eq @checkin.lng
    end

    it "should fog the last reported location's address if fogged" do
      # Make it fogged
      @device.switch_fog

      get :last, {
        user_id: @user.id,
        device_id: @device.id,
        type: "address"
      }

      expect(res_hash[:address]).to eq "Denham, GB"
      expect(res_hash[:lat]).to eq(51.57471)
      expect(res_hash[:lng]).to eq(-0.50626)
    end
  end

end