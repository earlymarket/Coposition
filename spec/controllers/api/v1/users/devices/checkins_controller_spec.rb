require 'rails_helper'

RSpec.describe Api::V1::Users::Devices::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros

  let(:developer){FactoryGirl::create :developer}
  let(:user){FactoryGirl::create :user}
  
  before do
    # Simulating all city records where name == Denham
    create_denhams
    @device = FactoryGirl::create :device
    @device.user = user
    @device.save!
    @checkin = FactoryGirl::build :checkin
    @checkin.uuid = @device.uuid
    @checkin.save!
    request.headers["X-Api-Key"] = developer.api_key
  end

  describe "endpoint without developer approval" do
    it "shouldn't fetch the last reported location" do
      get :last, {
        user_id: user.id,
        device_id: @device.id
      }
      expect(res_hash[:approval_status]).to be nil
    end
  end

  describe "endpoint with developer approval but not on specific device" do
    before do
      developer.request_approval_from(user)
      user.approve_developer(developer)
      @device.change_privilege_for(developer, 2)
    end

    it "shouldn't fetch the last reported location" do
      get :last, {
        user_id: user.id,
        device_id: @device.id
      }
      expect(response.body).to eq ""
      expect(response.status).to be 401
    end
  end

  describe "endpoint with approval" do

    before do
      developer.request_approval_from(user)
      user.approve_developer(developer)
    end

    it "should fetch the last reported location" do
      get :last, {
        user_id: user.id,
        device_id: @device.id
      }

      expect(res_hash[:lat]).to be_within(0.00001).of(@checkin.lat)
    end

    it "should fetch the last reported location's address in full by default" do
      get :last, {
        user_id: user.id,
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
        user_id: user.id,
        device_id: @device.id,
        type: "address"
      }

      expect(res_hash[:address]).to eq "Denham, GB"
      expect(res_hash[:lat]).to eq(51.57471)
      expect(res_hash[:lng]).to eq(-0.50626)
    end
  end

end