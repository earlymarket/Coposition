require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros

  let(:developer){FactoryGirl::create :developer}
  let(:user){FactoryGirl::create :user}
  let(:second_user){FactoryGirl::create :user}
  let(:device) do
    device = FactoryGirl::create :device
    user.devices << device
    device
  end
  let(:checkin) do
    checkin = FactoryGirl::create :checkin
    device.checkins << checkin
    checkin
  end
  let(:create_headers) { request.headers["X-UUID"] = device.uuid }
  let(:params) {{ user_id: user.id, device_id: device.id }}
  let(:create_params) {{ checkin: { lat: Faker::Address.latitude, lng: Faker::Address.longitude } }}

  before do |example|
    create_denhams
    api_request_headers(developer, user)
    unless example.metadata[:skip_before]
      device
      Approval.link(user,second_user,'User')
      Approval.accept(second_user,user,'User')
      Approval.link(user,developer,'Developer')
      Approval.accept(user,developer,'Developer')
    end
  end

  describe "GET #last" do
    context "without developer approval" do
      it "shouldn't fetch the last reported location", :skip_before do
        get :last, params
        expect(res_hash[:approval_status]).to be nil
      end
    end

    context "with developer approval but without friend approval" do
      it "shouldn't fetch the last reported location", :skip_before do
        device
        Approval.link(user,developer,'Developer')
        Approval.accept(user,developer,'Developer')
        get :last, params.merge(permissible_id: second_user.id)
        expect(res_hash[:approval_status]).to be nil
      end
    end

    context "with approval" do

      before do
        checkin
      end

      it "should fetch the last reported location" do
        get :last, params
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
      end

      it "should fetch the last reported location for a friend" do
        get :last, params.merge(permissible_id: second_user.id)
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
      end

      it "should fetch the last reported location's address in full by default" do
        get :last, params.merge(type: "address")
        expect(res_hash.first['address']).to eq "The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK"
        expect(res_hash.first['lat']).to eq checkin.lat
        expect(res_hash.first['lng']).to eq checkin.lng
      end

      it "should fog the last reported location's address if fogged" do
        device.switch_fog
        device.checkins.create(lat: 51.57471, lng: -0.50626)
        get :last, params.merge(type: "address")
        expect(res_hash.first['address']).to eq "Denham"
        expect(res_hash.first['lat']).to eq(51.57471)
        expect(res_hash.first['lng']).to eq(-0.50626)
      end

      it "should bypass fogging if bypass_fogging is true" do
        # Make it fogged
        device.switch_fog
        device.checkins.create(lat: 51.57471, lng: -0.50626)
        Permission.last.update(bypass_fogging: true)
        get :last, params.merge(type: "address")
        expect(res_hash.first['address']).to eq "The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK"
      end
    end

    context "on a user" do
      it "should fetch the last reported location" do
        checkin
        get :last, { user_id: user.id }
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
      end
    end
  end

  describe "GET #index when the device has 31 checkins" do
    before do
      31.times do
        checkin = FactoryGirl::create :checkin
        device.checkins << checkin
      end
    end

    context 'with no page param given' do
      it "should fetch the most recent checkins (up to 30 checkins)" do
        get :index, params
        expect(res_hash.first['id']).to be device.checkins.first.id
        expect(response.header['X-Next-Page']).to eq "2"
        expect(response.header['X-Current-Page']).to eq "1"
        expect(response.header['X-Total-Entries']).to eq "#{device.checkins.count}"
        expect(response.header['X-Per-Page']).to eq "30"
        expect(res_hash.size).to eq 30
      end
    end

    context 'with page param' do
      it "should fetch the checkins on that page if they exist" do
        page = 2
        get :index, params.merge(page: page)
        expect(res_hash.first['id']).to be device.checkins.last.id
        expect(response.header['X-Current-Page']).to eq "#{page}"
        expect(response.header['X-Next-Page']).to eq "null"
      end

      it "should not get any checkins if page does not exist" do
        get :index, params.merge(page: 3)
        expect(response.body).to eq "[]"
      end

    end

    context "on a user" do
      it "should fetch the most recent checkins (up to 30 checkins)" do
        get :index, { user_id: user.id }
        expect(res_hash.first['id']).to be device.checkins.first.id
      end
    end
  end

  describe "POST #create" do

    it "should create a checkin when there is a pre-existing device" do
      count = user.checkins.count
      create_headers
      post :create, create_params
      expect(res_hash.first['uuid']).to eq device.uuid
      expect(user.checkins.count).to be(count + 1)
      expect(checkin.device).to be device
    end

    it "should return 400 if you POST a checkin with missing parameters" do
      create_headers
      post :create,
        checkin: {
          lat: Faker::Address.latitude
        }
      expect(response.status).to eq(400)
      expect(res_hash[:message]).to eq('You must provide a lat and lng')
    end

    it "should return 400 if you POST a checkin with invalid uuid" do
      request.headers['X-UUID'] = 'thisdevicedoesntexist'
      post :create, create_params
      expect(response.status).to eq(400)
      expect(res_hash[:message]).to eq('You must provide a valid uuid')
    end

  end
end
