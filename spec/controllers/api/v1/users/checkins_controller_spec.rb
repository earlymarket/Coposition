require 'rails_helper'

RSpec.describe Api::V1::Users::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros

  let(:developer){FactoryGirl::create :developer}
  let(:user){FactoryGirl::create :user}
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

  before do |example|
    create_denhams
    request.headers["X-Api-Key"] = developer.api_key
    unless example.metadata[:skip_before]
      device
      Approval.link(user,developer,'Developer')
      Approval.accept(user,developer,'Developer')
    end
  end

  describe "GET #last" do
    context "without developer approval" do
      it "shouldn't fetch the last reported location", :skip_before do
        get :last, {
          user_id: user.id,
          device_id: device.id
        }
        expect(res_hash[:approval_status]).to be nil
      end
    end

    context "with developer approval but not on specific device" do
      before do
        device.permissions.last.update(privilege: 'disallowed')
      end

      it "shouldn't fetch the last reported location" do
        get :last, {
          user_id: user.id,
          device_id: device.id
        }
        expect(response.body).to eq ""
        expect(response.status).to be 401
      end
    end

    context "with approval" do

      before do
        checkin
      end

      it "should fetch the last reported location" do
        get :last, {
          user_id: user.id,
          device_id: device.id
        }
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
      end

      it "should fetch the last reported location's address in full by default" do
        get :last, {
          user_id: user.id,
          device_id: device.id,
          type: "address"
        }

        expect(res_hash.first['address']).to eq "The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK"
        expect(res_hash.first['lat']).to eq checkin.lat
        expect(res_hash.first['lng']).to eq checkin.lng
      end

      it "should fog the last reported location's address if fogged" do
        device.switch_fog
        device.checkins.create(lat: 51.57471, lng: -0.50626, uuid: device.uuid)
        get :last, {
          user_id: user.id,
          device_id: device.id,
          type: "address"
        }
        expect(res_hash.first['address']).to eq "Denham, GB"
        expect(res_hash.first['lat']).to eq(51.57471)
        expect(res_hash.first['lng']).to eq(-0.50626)
      end

      it "should bypass fogging if bypass_fogging is true" do
        # Make it fogged
        device.switch_fog
        device.checkins.create(lat: 51.57471, lng: -0.50626, uuid: device.uuid)
        Permission.last.update(bypass_fogging: true)
        get :last, {
          user_id: user.id,
          device_id: device.id,
          type: "address"
        }
        expect(res_hash.first['address']).to eq "The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK"
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
        get :index, {
          user_id: user.id,
          device_id: device.id
        }
        expect(res_hash.first['id']).to be device.checkins.last.id
        expect(response.header['X-Next-Page']).to eq "2"
        expect(response.header['X-Current-Page']).to eq "1"
        expect(response.header['X-Total-Entries']).to eq "#{device.checkins.count}"
        expect(response.header['X-Per-Page']).to eq "30"
      end
    end

    context 'with page param' do
      it "should fetch the checkins on that page if they exist" do
        page = 2
        get :index, {
          user_id: user.id,
          device_id: device.id,
          page: page
        }
        expect(res_hash.first['id']).to be device.checkins.first.id
        expect(response.header['X-Current-Page']).to eq "#{page}"
        expect(response.header['X-Next-Page']).to eq "null"
      end

      it "should not get any checkins if page does not exist" do
        get :index, {
          user_id: user.id,
          device_id: device.id,
          page: 3
        }
        expect(response.body).to eq "[]"
      end

      it "should not fetch checkins from before date of approval creation" do
        approval_date = user.approval_date_for(developer)
        checkin = FactoryGirl::create :checkin
        checkin.update(created_at: (approval_date - 1.day))
        device.checkins << checkin
        get :index, {
          user_id: user.id,
          device_id: device.id,
          page: 2
        }
        expect(res_hash.last['id']).to_not be device.checkins.last.id
      end

      it "should fetch checkins from before date of approval creation if show_history is true" do
        approval_date = user.approval_date_for(developer)
        checkin = FactoryGirl::create :checkin
        checkin.update(created_at: (approval_date - 1.day))
        device.checkins << checkin
        Permission.last.update(show_history: true)
        get :index, {
          user_id: user.id,
          device_id: device.id,
          page: 2
        }
        expect(res_hash.last['id']).to be device.checkins.last.id
      end
    end
  end

  describe "POST #create" do

    it "should POST a checkin with a pre-existing device" do
      count = Checkin.count
      post :create, {
        user_id: user.id,
        device_id: device.id,
        checkin: {
          uuid: device.uuid,
          lat: Faker::Address.latitude,
          lng: Faker::Address.longitude
        }
      }
      expect(res_hash.first['uuid']).to eq device.uuid
      expect(Checkin.count).to be(count + 1)
      expect(checkin.device).to be device
    end

    it "should return 400 if you POST a device with missing parameters" do
      post :create, {
        user_id: user.id,
        device_id: device.id,
        checkin: {
          uuid: Faker::Number.number(12),
          lat: Faker::Address.latitude
        }
      }
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq('message' => 'You must provide a UUID, lat and lng')
    end
  end

end
