require "rails_helper"

RSpec.describe Users::DashboardsController, type: :controller do
  include ControllerMacros
  let(:checkin) { create(:checkin, device: device) }
  let!(:device) do
    dev = create :device
    dev.checkins << [checkin, create(:checkin, device: dev, created_at: 10.days.ago)]
    dev
  end
  let(:user) do
    user = create_user
    user.devices << device
    user
  end
  let(:second_user) { create :user }
  let(:friend_device) { create :device, user_id: second_user.id, delayed: 10 }
  let!(:checkin) { create :checkin, device: friend_device }
  let!(:historic_checkin) { create :checkin, device: friend_device, created_at: Time.current - 1.day }
  let!(:approval) do
    device
    Approval.link(user, second_user, "User")
    Approval.accept(second_user, user, "User")
  end

  describe "GET #show" do
    it "loads metadata for dashboard page" do
      get :show, params: { user_id: user.id }
      expect((assigns :dashboard_presenter).most_used_device).to eq device
    end

    it "redirects to correct url if wrong user_id provided" do
      user
      get :show, params: { user_id: second_user.id }
      expect(response).to redirect_to(controller: "users/dashboards", action: "show", user_id: user.friendly_id)
    end

    context "permission disallowed" do
      it "renders no checkins" do
        friend_device.permission_for(user).update! privilege: "disallowed"
        get :show, params: { user_id: user.id }
        expect((assigns :dashboard_presenter).gon[:friends][0][:lastCheckin]).to be nil
      end
    end

    context "device cloaked" do
      it "renders no checkins" do
        friend_device.update! cloaked: true
        get :show, params: { user_id: user.id }
        expect((assigns :dashboard_presenter).gon[:friends][0][:lastCheckin]).to be nil
      end
    end

    context "permission complete, bypass delay false, bypass fogging false" do
      it "renders one historic fogged checkin" do
        friend_device.permission_for(user).update! privilege: "complete", bypass_delay: false, bypass_fogging: false
        get :show, params: { user_id: user.id }
        checkins = (assigns :dashboard_presenter).gon[:friends][0][:lastCheckin]
        expect(checkins["lat"].round(6)).to eq historic_checkin.fogged_lat.round(6)
        expect(checkins["id"]).to eq historic_checkin.id
      end
    end

    context "permission complete, bypass delay true, bypass fogging true" do
      it "renders one recent unfogged checkin" do
        friend_device.permission_for(user).update! privilege: "complete", bypass_delay: true, bypass_fogging: true
        get :show, params: { user_id: user.id }
        expect((assigns :dashboard_presenter).gon[:friends][0][:lastCheckin]["lat"].round(6)).to eq checkin.lat.round(6)
      end
    end
  end
end
