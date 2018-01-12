require "rails_helper"

RSpec.describe Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:empty_device) { create :device, user: nil }
  let(:device) { create :device, delayed: 10, user: nil }
  let(:checkin) { create(:checkin, lat: 10.5, lng: 10.5, device: user.devices.last) }
  let(:older_checkin) { create(:checkin, created_at: 1.hour.ago, device: user.devices.last) }
  let(:developer) do
    dev = create :developer
    dev.configs.create(device: device)
    dev
  end
  let(:user) do
    user = create_user
    user.devices << device
    user.devices.each do |device|
      device.developers << developer
      device.save
    end
    user
  end
  let(:new_user) { create_user }
  let(:approval) { create_approval(user, new_user) }
  let(:user_param) { { user_id: user.username } }
  let(:params) { user_param.merge(id: device.id) }
  let(:date_params) { params.merge(from: Date.yesterday, to: Date.yesterday) }

  it "has a current_user" do
    user
    expect(subject.current_user).to_not be nil
  end

  describe "GET #index" do
    it "assigns current_user.devices to @devices" do
      get :index, params: user_param
      expect(assigns(:devices_index_presenter).devices).to eq(user.devices)
      expect(assigns(:devices_index_presenter).devices.first).to eq(device)
    end
  end

  describe "GET #show" do
    it "assigns :id.device to @device if user owns device" do
      get :show, params: params
      expect(assigns(:device_show_presenter).device).to eq(Device.find(device.id))
    end

    it "does not assign to @device if user does not own device" do
      get :show, params: params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(assigns(:device_show_presenter)).to eq(nil)
    end

    it "redirects to root path and render error message if device doesnt exist" do
      get :show, params: params.merge(id: 1000)
      expect(flash[:alert]).to eq "Couldn't find Device with 'id'=1000"
      expect(response).to redirect_to(root_path)
    end

    it "creates a CSV file if .csv appended to url" do
      checkin.reload
      get :show, params: params.merge(format: :csv, download: "csv")
      expect(response.header["Content-Type"]).to include "text/csv"
      expect(response.body).to include(*checkin.attributes.keys)
      expect(response.body).to include(checkin.attributes.values[1, 5].join(","))
    end

    it "creates a GPX file if .gpx appended to url" do
      get :show, params: params.merge(format: :gpx, download: "gpx")
      expect(response.header["Content-Type"]).to include "application/gpx+xml"
      expect(response.body).to include("http://www.topografix.com/GPX/1/1/gpx.xsd")
    end

    it "creates a geojson file if .json appended to url" do
      get :show, params: params.merge(format: :geojson, download: "geojson")
      expect(response.header["Content-Type"]).to include "application/geojson"
      expect(response.body).to include(device.checkins.to_geojson.to_s)
    end
  end

  describe "GET #new" do
    it "assigns :uuid to @device.uuid if exists" do
      get :new, params: user_param
      expect(assigns(:device).uuid).to eq(nil)
      get :new, params: user_param.merge(uuid: "123412341234")
      expect(assigns(:device).uuid).to eq("123412341234")
    end
  end

  describe "GET #shared" do
    it "denies access if device not published or cloaked" do
      get :shared, params: params
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to match("Could not find ")
      device.update! published: true, cloaked: true
      get :shared, params: params
      expect(response).to redirect_to(root_path)
    end

    it "renders page if published and checkin is fogged" do
      checkin
      older_checkin
      device.update(published: true)
      get :shared, params: params
      expect(response).to render_template("shared")
      expect(assigns(:devices_shared_presenter).shared_gon[:checkin]["lat"].round(6)).to eq older_checkin.fogged_lat.round(6)
    end

    it "renders page if published and checkin is unfogged if unfogged" do
      device.update(published: true, fogged: false)
      checkin
      older_checkin
      get :shared, params: params
      expect(assigns(:devices_shared_presenter).shared_gon[:checkin]["lat"]).to eq older_checkin.lat
    end
  end

  describe "GET #info" do
    it "renders info page" do
      get :info, params: params
      expect(response).to render_template("info")
    end
  end

  describe "POST #create" do
    it "creates a new device and config" do
      device_count = user.devices.count
      config_count = Config.count
      post :create, params: user_param.merge(device: { name: "New Device" })
      expect(response.code).to eq "302"
      expect(Config.count).to be config_count + 1
      expect(user.devices.count).to be device_count + 1
      expect(user.devices.all.last.name).to eq "New Device"
    end

    it "creates a device with a given UUID" do
      count = user.devices.count
      post :create, params: user_param.merge(device: { name: "New Device", uuid: empty_device.uuid })
      expect(response.code).to eq "302"
      expect(user.devices.count).to be count + 1
      expect(user.devices.all.last).to eq empty_device
    end

    it "creates a device with a given icon" do
      post :create, params: user_param.merge(device: { name: "New Device", icon: "tablet" })
      expect(user.devices.all.last.icon).to eq "tablet"
    end

    it "creates a new device and a checkin if location provided" do
      devices_count = user.devices.count
      checkins_count = Checkin.count
      post :create, params: user_param.merge(
        location: "-0.513069, 51.588330",
        device: { name: "New Device" },
        create_checkin: true
      )
      expect(user.devices.count).to be devices_count + 1
      expect(Checkin.count).to be checkins_count + 1
      expect(Checkin.last.lat).to eq 51.588330
    end

    it "fails to to create a device with an invalid UUID" do
      count = user.devices.count
      post :create, params: user_param.merge(device: { uuid: 123 })
      expect(flash[:notice]).to match "does not match"
      expect(response).to redirect_to(new_user_device_path)
      expect(user.devices.count).to be count
    end

    it "fails to to create a device when the device is assigned to a user" do
      count = user.devices.count
      taken_uuid = user.devices.last.uuid
      post :create, params: user_param.merge(device: { uuid: taken_uuid })
      expect(response).to redirect_to(new_user_device_path)
      expect(flash[:notice]).to match "registered to another"
      expect(user.devices.count).to be count
    end

    it "fails to to create a device with a duplicate username" do
      taken_name = user.devices.last.name
      count = user.devices.count
      post :create, params: user_param.merge(device: { name: taken_name })
      expect(user.devices.count).to be count
      expect(response).to redirect_to(new_user_device_path)
      expect(flash[:notice]).to match taken_name
    end
  end

  describe "PUT #update" do
    it "switches fogging status by default" do
      expect(device.fogged?).to be true
      request.accept = "text/javascript"
      put :update, params: params.merge(device: { fogged: false })

      device.reload
      expect(device.fogged?).to be false
      expect(flash[:notice]).to match "Location fogging is"
    end

    it "switches published status" do
      expect(device.published?).to be false
      request.accept = "text/javascript"
      put :update, params: params.merge(device: { published: true })
      expect(flash[:notice]).to match "Location sharing is"
      device.reload
      expect(device.published?).to be true
    end

    it "sets a delay" do
      request.accept = "text/javascript"
      put :update, params: params.merge(delayed: 5)
      expect(flash[:notice]).to include "minutes"
      put :update, params: params.merge(delayed: 100)
      expect(flash[:notice]).to include "hour"
      put :update, params: params.merge(delayed: 1440)
      expect(flash[:notice]).to include "day"
      device.reload
      expect(device.delayed).to be 1440
    end

    it "sets a delay of 0 as nil" do
      request.accept = "text/javascript"
      put :update, params: params.merge(delayed: 0)

      device.reload
      expect(device.delayed).to be 0
    end

    it "updates device name" do
      put :update, params: params.merge(device: { name: "Computer" }, format: :json)
      expect(device.reload.name).to eq "Computer"
    end

    it "fails to update device name if taken" do
      other = user.devices.create(name: "Computer")
      put :update, params: params.merge(device: { name: other.name }, format: :json)
      expect(device.reload.name).to_not eq "Computer"
      expect(response.body).to match "already been taken"
    end

    it "switches cloaked status" do
      expect(device.cloaked?).to be false
      request.accept = "text/javascript"
      put :update, params: params.merge(device: { cloaked: true })
      expect(flash[:notice]).to match "Device cloaking is"
      device.reload
      expect(device.cloaked?).to be true
    end

    it "changes icon" do
      expect(device.icon).to eq "devices_other"
      request.accept = "text/javascript"
      put :update, params: params.merge(device: { icon: "tablet" })
      expect(flash[:notice]).to match "Device icon updated"
      device.reload
      expect(device.icon).to eq "tablet"
    end
  end

  describe "DELETE #destroy" do
    it "calls DeleteDeviceWorker" do
      user
      allow(DeleteDeviceWorker).to receive(:perform_async).with(device.id.to_s)
      delete :destroy, params: params
      expect(DeleteDeviceWorker).to have_received(:perform_async)
    end

    it "does not call DeleteDeviceWorker if user does not own device" do
      user
      allow(DeleteDeviceWorker).to receive(:perform_async).with(device.id.to_s)
      delete :destroy, params: params.merge(user_id: new_user.username)
      expect(DeleteDeviceWorker).not_to have_received :perform_async
    end
  end
end
