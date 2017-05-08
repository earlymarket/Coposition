require "rails_helper"

RSpec.describe Users::FriendsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:second_user) { create :user }
  let!(:device) { create :device, user_id: second_user.id, delayed: 10 }
  let!(:checkin) { create :checkin, device: device }
  let!(:historic_checkin) { create :checkin, device: device, created_at: Time.current - 1.day }
  let!(:approval) do
    device
    Approval.link(user, second_user, "User")
    Approval.accept(second_user, user, "User")
  end
  let(:params) { { id: second_user.id, user_id: user.id, device_id: device.id } }
  let(:paginate_params) { params.merge(per_page: 1000, page: 1) }

  describe "GET #show" do
    context "permission disallowed" do
      it "renders no checkins" do
        device.permission_for(user).update! privilege: "disallowed"
        get :show, params: params
        expect((assigns :friend_show_presenter).gon[:checkins].size).to eq 0
      end
    end

    context "device cloaked" do
      it "renders no checkins" do
        device.update! cloaked: true
        get :show, params: params
        expect((assigns :friend_show_presenter).gon[:checkins].size).to eq 0
      end
    end

    context "permission complete, bypass delay false, bypass fogging false" do
      before do
        device.permission_for(user).update! privilege: "complete", bypass_delay: false, bypass_fogging: false
      end

      it "renders one checkin" do
        get :show, params: params
        checkins = (assigns :friend_show_presenter).gon[:checkins]
        expect(checkins.size).to eq 1
      end

      it "renders fogged checkin" do
        get :show, params: params
        checkins = (assigns :friend_show_presenter).gon[:checkins]
        expect(checkins[0]["lat"].round(6)).to eq historic_checkin.fogged_lat.round(6)
      end

      it "renders historic checkin" do
        get :show, params: params
        checkins = (assigns :friend_show_presenter).gon[:checkins]
        expect(checkins[0]["id"]).to eq historic_checkin.id
      end
    end

    context "permission complete, bypass delay true, bypass fogging true" do
      before do
        device.permission_for(user).update! privilege: "complete", bypass_delay: true, bypass_fogging: true
      end

      it "renders unfogged checkin" do
        get :show, params: params
        expect((assigns :friend_show_presenter).gon[:checkins][0]["lat"].round(6)).to eq checkin.lat.round(6)
      end

      it "renders recent checkin" do
        get :show, params: params
        expect((assigns :friend_show_presenter).gon[:checkins][0]["id"]).to eq checkin.id
      end
    end

    it "says that you are not friends with user" do
      Approval.all.destroy_all
      get :show, params: params
      expect(flash[:notice]).to match "not friends"
    end
  end

  describe "GET #show_device" do
    it "renders the show device page" do
      get :show_device, params: params
      expect(response.code).to eq "200"
    end

    context "permission disallowed" do
      it "renders no checkins" do
        device.permission_for(user).update! privilege: "disallowed"
        get :show_device, params: params
        expect((assigns :device_show_presenter).gon[:checkins].size).to eq 0
      end
    end

    context "device cloaked" do
      it "fails to render" do
        device.update! cloaked: true
        get :show_device, params: params
        expect((assigns :device_show_presenter)).to eq nil
      end
    end

    context "permission last_only, bypass delay false" do
      it "renders one historic_checkin" do
        device.permission_for(user).update! privilege: "last_only", bypass_delay: false
        get :show_device, params: params
        expect((assigns :device_show_presenter).gon[:checkins].size).to eq 1
        expect((assigns :device_show_presenter).gon[:checkins][0]["id"]).to eq historic_checkin.id
      end
    end

    context "permission last_only, bypass delay true" do
      it "renders one recent checkin" do
        device.permission_for(user).update! privilege: "last_only", bypass_delay: true
        get :show_device, params: params
        expect((assigns :device_show_presenter).gon[:checkins][0]["id"]).to eq checkin.id
        expect((assigns :device_show_presenter).gon[:checkins].size).to eq 1
      end
    end

    context "permission complete, bypass delay false, bypass fogging false" do
      it "renders one historic fogged checkin" do
        device.permission_for(user).update! privilege: "complete", bypass_delay: false, bypass_fogging: false
        get :show_device, params: params
        checkins = (assigns :device_show_presenter).gon[:checkins]
        expect(checkins[0]["id"]).to eq historic_checkin.id
        expect(checkins[0]["lat"].round(6)).to eq historic_checkin.fogged_lat.round(6)
        expect(checkins.size).to eq 1
      end
    end

    context "permission complete, bypass delay true, bypass fogging true" do
      it "renders two unfogged checkins" do
        device.permission_for(user).update! privilege: "complete", bypass_delay: true, bypass_fogging: true
        get :show_device, params: params
        expect((assigns :device_show_presenter).gon[:checkins].size).to eq 2
        expect((assigns :device_show_presenter).gon[:checkins][0]["lat"].round(6)).to eq checkin.lat.round(6)
      end
    end

    context "with paginate params" do
      it "renders json" do
        get :show_device, params: paginate_params
        expect(res_hash).to be_truthy
      end

      it "renders json which contains checkins" do
        get :show_device, params: paginate_params
        expect(res_hash[:checkins]).to be_truthy
      end

      it "renders a checkin" do
        get :show_device, params: paginate_params
        expect(Checkin.find(res_hash[:checkins][0]["id"])).to be_kind_of Checkin
      end
    end
  end
end
