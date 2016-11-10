require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros

  let(:developer) { FactoryGirl.create :developer }
  let(:user) { FactoryGirl.create :user }
  let(:second_user) { FactoryGirl.create :user }
  let(:device) do
    device = FactoryGirl.create :device
    user.devices << device
    device
  end
  let(:checkin) { FactoryGirl.create :checkin, device: device }
  let(:subscription) { FactoryGirl.create :subscription, subscriber: user }
  let(:friend_sub) { FactoryGirl.create :subscription, subscriber: second_user, event: 'friend_new_checkin' }
  let(:create_headers) { request.headers['X-UUID'] = device.uuid }
  let(:address) { 'The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK' }
  let(:params) { { user_id: user.id, device_id: device.id } }
  let(:geocode_params) { params.merge(type: 'address') }
  let(:create_params) { { checkin: { lat: Faker::Address.latitude, lng: Faker::Address.longitude } } }
  let(:foggable_checkin_attributes) { %w(city postal_code) }
  let(:private_checkin_attributes) { %w(uuid fogged fogged_lat fogged_lng fogged_city) }
  let(:private_and_foggable_checkin_attributes) { private_checkin_attributes + foggable_checkin_attributes }

  before do |example|
    create_denhams
    api_request_headers(developer, user)
    unless example.metadata[:skip_before]
      device
      Approval.link(user, second_user, 'User')
      Approval.accept(second_user, user, 'User')
      Approval.link(user, developer, 'Developer')
      Approval.accept(user, developer, 'Developer')
    end
  end

  shared_context 'from copo app' do
    before do
      request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
      checkin
    end
  end

  describe 'GET #last' do
    context 'without developer approval' do
      it "shouldn't fetch the last reported location", :skip_before do
        get :last, params: params
        expect(res_hash[:error]).to eq 'approval_status: No Approval'
      end
    end

    context 'with developer approval but without friend approval' do
      it "shouldn't fetch the last reported location", :skip_before do
        device
        Approval.link(user, developer, 'Developer')
        Approval.accept(user, developer, 'Developer')
        get :last, params: params.merge(permissible_id: second_user.id)
        expect(res_hash[:error]).to eq 'approval_status: No Approval'
      end
    end

    context 'with approval' do
      before do
        device.switch_fog
        checkin
      end

      it 'should fetch the last reported location (public attributes only)' do
        get :last, params: params
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
        expect(res_hash.first.keys).not_to include(*private_checkin_attributes)
      end

      it 'should fetch the last reported location for a friend' do
        get :last, params: params.merge(permissible_id: second_user.id)
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
      end

      it "should fetch the last reported location's address in full by default" do
        get :last, params: geocode_params
        expect(res_hash.first['address']).to eq address
        expect(res_hash.first['lat']).to eq checkin.lat
        expect(res_hash.first['lng']).to eq checkin.lng
      end

      it "should fog the last reported location's address if fogged" do
        device.switch_fog
        device.checkins.create(lat: 51.57471, lng: -0.50626)
        get :last, params: geocode_params
        expect(res_hash.first['address']).to eq 'Denham'
        expect(res_hash.first['lat']).to eq(51.57471)
        expect(res_hash.first['lng']).to eq(-0.50626)
        expect(res_hash.first.keys).not_to include(*private_and_foggable_checkin_attributes)
      end

      it 'should bypass fogging if bypass_fogging is true' do
        # Make it fogged
        device.switch_fog
        device.checkins.create(lat: 51.57471, lng: -0.50626)
        Permission.last.update(bypass_fogging: true)
        get :last, params: geocode_params
        expect(res_hash.first['address']).to eq address
        expect((foggable_checkin_attributes - res_hash.first.keys).empty?).to be true
      end
    end

    context 'on a user' do
      it 'should fetch the last reported location' do
        device.switch_fog
        checkin
        get :last, params: { user_id: user.id }
        expect(res_hash.first['lat']).to be_within(0.00001).of(checkin.lat)
      end
    end

    context 'from coposition app' do
      include_context 'from copo app'

      it "should fetch the user's last device checkin with all attributes" do
        get :last, params: params
        expect(res_hash.first['id']).to be checkin.id
        expect(res_hash.first.keys).to eq checkin.attributes.keys
      end

      it 'should geocode last checkin if type param provided' do
        get :last, params: geocode_params
        expect(res_hash.first['city']).to eq 'Denham'
      end
    end
  end

  describe 'GET #index when the device has 31 checkins' do
    before do
      31.times do
        checkin = FactoryGirl.create :checkin
        device.permission_for(developer).update(privilege: 'complete')
        device.checkins << checkin
      end
    end

    context 'with no page param given' do
      it 'should fetch the most recent checkins (up to 30 checkins)' do
        get :index, params: params
        expect(res_hash.first['id']).to be device.checkins.first.id
        expect(response.header['X-Next-Page']).to eq '2'
        expect(response.header['X-Current-Page']).to eq '1'
        expect(response.header['X-Total-Entries']).to eq device.checkins.count.to_s
        expect(response.header['X-Per-Page']).to eq '30'
        expect(res_hash.size).to eq 30
      end
    end

    context 'with page param' do
      it 'should fetch the checkins on that page if they exist' do
        page = 2
        get :index, params: params.merge(page: page)
        expect(res_hash.first['id']).to be device.checkins.last.id
        expect(response.header['X-Current-Page']).to eq page.to_s
        expect(response.header['X-Next-Page']).to eq 'null'
      end

      it 'should not get any checkins if page does not exist' do
        get :index, params: params.merge(page: 3)
        expect(response.body).to eq '[]'
      end
    end

    context 'on a user' do
      it 'should fetch the most recent checkins (up to 30 checkins)' do
        get :index, params: { user_id: user.id }
        expect(res_hash.first['id']).to be device.checkins.first.id
      end
    end

    context 'copo mobile app' do
      include_context 'from copo app'

      it "should fetch all the user's device checkins" do
        get :index, params: params
        expect(res_hash.first.keys).to eq checkin.attributes.keys
        expect(res_hash.first['id']).to be checkin.id
      end

      it 'should geocode all checkins with type address' do
        get :index, params: geocode_params
        expect(res_hash.first['address']).to match 'The Pilot Centre'
      end
    end
  end

  describe 'POST #create' do
    it 'should create a checkin when there is a pre-existing device' do
      subscription
      friend_sub
      count = user.checkins.count
      create_headers
      post :create, params: create_params
      expect(res_hash[:data].first['uuid']).to eq device.uuid
      expect(user.checkins.count).to be(count + 1)
      expect(checkin.device).to be device
    end

    it 'should return 400 if you POST a checkin with missing parameters' do
      create_headers
      post :create, params: { checkin: { lat: Faker::Address.latitude } }
      expect(response.status).to eq(400)
      expect(res_hash[:error]).to eq('You must provide a lat and lng')
    end

    it 'should return 400 if you POST a checkin with invalid uuid' do
      request.headers['X-UUID'] = 'thisdevicedoesntexist'
      post :create, params: create_params
      expect(response.status).to eq(400)
      expect(res_hash[:error]).to eq('You must provide a valid uuid')
    end
  end
end
