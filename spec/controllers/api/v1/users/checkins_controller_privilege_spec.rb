require 'rails_helper'

RSpec.describe Api::V1::Users::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros

  let(:developer){FactoryGirl::create :developer}
  let(:user){FactoryGirl::create :user}
  let(:second_user){FactoryGirl::create :user}
  let(:device){FactoryGirl::create :device, user_id: user.id}
  let(:second_device){FactoryGirl::create :device, user_id: user.id}
  let(:checkin){FactoryGirl::create :checkin, device_id: device.id}
  let(:historic_checkin) do
    ad = user.approval_for(second_user).approval_date
    FactoryGirl::create :checkin, device_id: device.id, created_at: ad - 1.day
  end
  let(:params) {{ user_id: user.id, device_id: device.id }}

  before do
    request.headers["X-Api-Key"] = developer.api_key
    device
    Approval.link(user,second_user,'User')
    Approval.accept(second_user,user,'User')
    Approval.link(user,developer,'Developer')
    Approval.accept(user,developer,'Developer')
  end

  def init_priv_start(privilege, show_history_state=false)
    device.permission_for(developer).update! privilege: privilege
    device.permission_for(developer).update! show_history: show_history_state
  end

  describe "GET #last" do

    context 'with 2 checkins: 1 old, 1 new.' do
      before do
        historic_checkin
        checkin
      end

      context "with privilege set to disallowed and can_show_history set to false" do
        it "should return 0 checkins" do
          init_priv_start(0)
          get :last, params
          expect(res_hash.size).to be(0)
        end
      end

      context "with privilege set to disallowed and can_show_history set to true" do
        it "should return 0 checkins" do
          init_priv_start(0, true)
        end
      end

      context "with privilege set to last_only and can_show_history set to true" do
        it "should return 1 new checkin" do
          init_priv_start(1, true)
          get :last, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end

      context "with privilege set to last_only and can_show_history set to false" do
        it "should return 1 new checkin" do
          init_priv_start(1)
          get :last, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end

      context "with privilege set to complete and can_show_history set to true" do
        it "should return 1 new checkin" do
          init_priv_start(2, true)
          get :last, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end

      context "with privilege set to complete and can_show_history set to false" do
        it "should return 1 new checkin" do
          init_priv_start(2)
          get :last, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end
    end

    context 'with 1 historic checkin' do

      before do
        historic_checkin
      end

      context "with privilege set to disallowed and can_show_history set to false" do
        it "should return 0 checkins" do
          init_priv_start(0)
          get :last, params
          expect(res_hash.size).to be(0)
        end
      end

      context "with privilege set to disallowed and can_show_history set to true" do
        it "should return 0 checkins" do
          init_priv_start(0, true)
          get :last, params
          expect(res_hash.size).to be(0)
        end
      end

      context "with privilege set to last_only and can_show_history set to true" do
        it "should return 1 historic checkin" do
          init_priv_start(1, true)
          get :last, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(historic_checkin.id)
        end
      end

      context "with privilege set to last_only and can_show_history set to false" do
        it "should return 0 checkins" do
          device.permission_for(developer).update! privilege: 0
          get :last, params
          expect(res_hash.size).to be(0)
        end
      end

      context "with privilege set to complete and can_show_history set to true" do
        it "should return 1 historic checkin" do
          init_priv_start(2, true)
          get :last, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(historic_checkin.id)
        end
      end

      context "with privilege set to complete and can_show_history set to false" do
        it "should return 0 checkins" do
          device.permission_for(developer).update! privilege: 0
          get :last, params
          expect(res_hash.size).to be(0)
        end
      end

    end

  end

  describe "GET #index" do

    context 'with 2 checkins: 1 old, 1 new.' do
      before do
        historic_checkin
        checkin
      end

      context "with privilege set to disallowed and can_show_history set to false" do
        it "should return 0 checkins" do
          init_priv_start(0)
          get :index, params
          expect(res_hash.size).to be(0)
        end
      end

      context "with privilege set to disallowed and can_show_history set to true" do
        it "should return 0 checkins" do
          init_priv_start(0, true)
          get :index, params
          expect(res_hash.size).to be(0)
        end
      end

      context "with privilege set to last_only and can_show_history set to true" do
        it "should return 1 new checkin" do
          init_priv_start(1, true)
          get :index, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end

      context "with privilege set to last_only and can_show_history set to false" do
        it "should return 1 new checkin" do
          init_priv_start(1)
          get :index, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end

      context "with privilege set to complete and can_show_history set to true" do
        it "should return 2 checkins" do
          init_priv_start(2, true)
          get :index, params
          expect(res_hash.size).to be(2)
        end
      end

      context "with privilege set to complete and can_show_history set to false" do
        it "should return 1 new checkin" do
          init_priv_start(2)
          get :index, params
          expect(res_hash.size).to be(1)
          expect(res_hash.first['id']).to be(checkin.id)
        end
      end
    end

  end

end
