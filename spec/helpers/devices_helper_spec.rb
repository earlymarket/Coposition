require "rails_helper"

RSpec.describe DevicesHelper, type: :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }
  let(:developer) { FactoryGirl.create :developer }
  let(:user) { FactoryGirl.create :user }
  let(:device) do
    device = FactoryGirl.create(:device, user_id: user.id)
    device.developers << developer
    device.permitted_users << user
    device
  end
  let(:config) { developer.configs.create(device_id: device.id) }
  let(:custom_config) do
    config.update(custom: { type: "herds", mode: "power-saving" })
    config
  end
  let(:other) { Device.update(device.id, published: true) }
  let(:friend) { FactoryGirl.create :user }
  let(:friendPresenter) { ::Users::FriendsPresenter.new(friend, { id: user.id, device_id: device.id }, "show_device") }
  let(:devicesPresenter) { ::Users::DevicesPresenter.new(user, { id: device.id }, "show") }

  describe "#devices_permitted_actors_for" do
    it "returns the devices developers and permitted users" do
      expect(helper.devices_permitted_actors_for(device)).to include(developer && user)
    end
  end

  describe "#devices_last_checkin" do
    it "returns 'No Checkins found' if a checkin doesn't exist" do
      expect(helper.devices_last_checkin(device)).to match("No Checkins found")
    end

    it "returns the last checkin address if it exists" do
      checkin = FactoryGirl.create(:checkin, device_id: device.id)
      expect(helper.devices_last_checkin(device)).to include(checkin.address)
    end
  end

  describe "#devices_shared_link" do
    it "return nothing if not published" do
      expect(helper.devices_shared_link(device)).to be(nil)
    end

    it "returns a string" do
      expect(helper.devices_shared_link(other)).to be_kind_of(String)
    end

    it "return the path to the shared device if device is published" do
      # http://test.host/users/1/devices/5/shared
      expect(helper.devices_shared_link(other))
        .to match(%r{http://.+/users/#{device.user_id}/devices/#{device.id}/shared*+})
    end
  end

  describe "#devices_config_row" do
    it "returns one row if no custom" do
      output = helper.devices_config_rows(config)
      expect(output).to match "No additional config"
      expect(output.scan(/<tr>/).count).to eq 1
    end

    it "returns each attribute and value of custom in a new row" do
      output = helper.devices_config_rows(custom_config)
      expect(output).to match custom_config.custom.keys.first.to_s
      expect(output.scan(/<tr>/).count).to eq custom_config.custom.count
    end
  end

  describe "#devices_label" do
    context "on friends page" do
      it "contains friend name and device name" do
        output = helper.devices_label(friendPresenter)
        expect(output).to match device.name
        expect(output).to match helper.name_or_email_name(user)
      end
    end

    context "on personal page" do
      it "contains device name" do
        output = helper.devices_label(devicesPresenter)
        expect(output).to_not match "Friend:"
        expect(output).to match device.name
      end
    end
  end

  describe "devices_cloaked_info" do
    it "returns nothing unless argument is true" do
      expect(helper.devices_cloaked_info(false)).to eq nil
    end

    it "returns a string if argument is true" do
      expect(helper.devices_cloaked_info(true)).to be_kind_of String
    end

    it "returns a string stating the device is cloaked if true" do
      expect(helper.devices_cloaked_info(true)).to match "device is cloaked"
    end
  end

  describe "devices_choose_icon" do
    before do
      allow(helper).to receive(:current_user) { user }
    end

    it "returns a string" do
      expect(helper.devices_choose_icon(device, "laptop")).to be_kind_of String
    end

    it "returns a string with active class if icon matches device icon" do
      expect(helper.devices_choose_icon(device, device.icon)).to match "active"
    end

    it "returns a string with choose-icon class if icon doesn't match device icon" do
      expect(helper.devices_choose_icon(device, "desktop")).to match "choose-icon"
    end
  end

  describe "icon_label" do
    it "returns a string" do
      expect(helper.icon_label("laptop")).to be_kind_of String
    end

    it "returns desktop label for desktop_windows" do
      expect(helper.icon_label("desktop_windows")).to match "desktop"
    end

    it "returns other label for devices_other" do
      expect(helper.icon_label("devices_other")).to match "other"
    end

    it "returns icon label for other icons" do
      icon = Faker::Name.first_name
      expect(helper.icon_label(icon)).to match icon
    end
  end
end
