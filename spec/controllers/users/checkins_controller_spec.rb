require "rails_helper"

RSpec.describe Users::CheckinsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:device) { create :device, user_id: user.id }
  let(:new_user) { create_user }
  let(:checkin) { create :checkin, device: device }
  let(:params) { { user_id: user.username, device_id: device.id, id: checkin.id } }
  let(:other_user_params) { params.merge(user_id: new_user.id) }
  let(:create_params) do
    params.merge(checkin: { lat: checkin.lat, lng: checkin.lng, speed: checkin.speed, altitude: checkin.altitude })
  end
  let(:index_params) { params.merge(page: 1, per_page: 1000) }
  let(:update_lat_params) { params.merge(checkin: { lat: 10 }) }

  describe "GET #new" do
    it "assigns a new checkin to @checkin" do
      get :new, params: params
      expect(assigns(:checkin)).to be_a_new(Checkin)
    end
  end

  describe "GET #index" do
    before { get :index, params: index_params }

    it "render json hash" do
      expect(res_hash).to be_truthy
    end

    it "renders hash with checkins" do
      expect(res_hash[:checkins]).to be_truthy
    end

    it "renders hash with current user id" do
      expect(res_hash[:current_user_id]).to eq user.id
    end

    it "renders hash with total checkins count" do
      expect(res_hash[:total]).to eq device.checkins.count
    end
  end

  describe "POST #create" do
    before do
      checkin
      request.accept = "text/javascript"
    end

    it "assigns a device" do
      post :create, params: create_params
      expect(assigns(:device)).to eq device
    end

    it "creates a new checkin" do
      expect { post :create, params: create_params }.to change { device.checkins.count }.by(1)
    end

    it "assigns new checkin to @checkin" do
      post :create, params: create_params
      expect(assigns(:checkin)["id"]).to eq device.checkins.first.id
    end

    it "returns an alert if inavlid lat/lng given" do
      checkin.lat = 200
      post :create, params: create_params
      expect(flash[:alert]).to match("Invalid")
    end
  end

  describe "GET #show" do
    before { request.accept = "text/javascript" }

    it "assigns :id.checkin to @checkin if user owns device which owns checkin" do
      get :show, params: params
      expect(assigns(:checkin)).to eq(Checkin.find(checkin.id))
    end

    it "doesn't assign :id.checkin if user does not own device which owns checkin" do
      user
      get :show, params: params.merge(user_id: new_user.username)
      expect(assigns(:checkin)).to eq nil
    end

    it "redirects to root_path if user does not own device" do
      user
      get :show, params: params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PUT #update" do
    before { request.accept = "text/javascript" }

    it "switches fogging if no extra params" do
      expect { put :update, params: params }.to change { Checkin.find(checkin.id).fogged }
    end

    it "updates lat/lng if valid lat/lng provided" do
      expect { put :update, params: update_lat_params }.to change { Checkin.find(checkin.id).lat }.to(10)
    end
  end

  describe "DELETE #destroy_all" do
    before do
      checkin
    end

    it "deletes all checkins belonging to a device if user owns device" do
      expect { delete :destroy_all, params: params }.to change { device.checkins.count }.by(-1)
    end

    it "doesn't delete all checkins if user does not own device" do
      expect { delete :destroy_all, params: other_user_params }.to change { device.checkins.count }.by(0)
    end

    it "redirects to root_path if user does not own device" do
      delete :destroy_all, params: other_user_params
      expect(response).to redirect_to(root_path)
    end

    context "with date params" do
      before(:example) {
        # create 3 days of checkins
        create(:checkin, device: device, created_at: 3.days.ago)
        create(:checkin, device: device, created_at: 2.days.ago)
        create(:checkin, device: device, created_at: 1.day.ago)
      }

      it "deletes 3 checkins when 3 days in range specified" do
        expect {
          delete :destroy_all, params: params.merge(from: 3.days.ago, to: 1.day.ago)
        }.to change { device.checkins.count }.by(-3)
      end

      it "deletes 1 checkin when 1 day in range specified" do
        expect {
          delete :destroy_all, params: params.merge(from: 1.day.ago, to: 1.day.ago)
        }.to change { device.checkins.count }.by(-1)
      end

      it "does not delete checkins when no days in range specified" do
        expect {
          delete :destroy_all, params: params.merge(from: 6.days.ago, to: 5.day.ago)
        }.to change { device.checkins.count }.by(0)
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      checkin
      request.accept = "text/javascript"
    end

    it "deletes a checkin by id" do
      expect { delete :destroy, params: params }.to change { device.checkins.count }.by(-1)
    end

    it "doesn't delete a checkin if it does not belong to the user" do
      expect { delete :destroy, params: other_user_params }.to change { device.checkins.count }.by(0)
    end

    it "redirects to root page if checkin doesn't belong to user" do
      delete :destroy, params: other_user_params
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #import" do
    let(:file) { fixture_file_upload("files/test_file.csv", "text/csv") }

    it "returns an alert message and rediercts if invalid file" do
      allow(CSV).to receive(:foreach).and_return(false)
      post :import, params: params.merge(file: file)
      expect(flash[:alert]).to match("Invalid file format")
      expect(response).to redirect_to(user_devices_path(user.url_id))
    end

    it "returns a helpful message if import succeeds" do
      post :import, params: params.merge(file: file)
      expect(flash[:notice]).to match("Importing check-ins")
    end
  end
end
