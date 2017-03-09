require "rails_helper"

RSpec.describe Users::Devices::CreateDevice, type: :service do
  subject(:create_device) { described_class.new(user, developer, params) }

  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
  let(:params) { { name: "laptop", icon: "laptop" } }

  describe "Interface" do
    %i(save? error device).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "public methods" do
    context "device" do
      it "returns the device specified in initializer" do
        expect(create_device.device).to be_kind_of Device
      end
    end

    context "save?" do
      it "calls device.construct" do
        device = Device.new
        allow(Device).to receive(:new).and_return(device)
        allow(device).to receive(:construct)
        create_device.save?
        expect(device).to have_received(:construct)
      end

      it "creates device config" do
        expect { create_device.save? }.to change { Config.count }.by(1)
      end

      it "calls notify_subscribers" do
        device = Device.new
        allow(Device).to receive(:new).and_return(device)
        allow(device).to receive(:notify_subscribers)
        create_device.save?
        expect(device).to have_received(:notify_subscribers)
      end

      it "returns true if successful" do
        expect(create_device.save?).to eq true
      end

      it "returns falsey if invalid uuid" do
        create_device = described_class.new(user, developer, uuid: "invalid")
        expect(create_device.save?).to be_falsey
      end

      it "returns falsey if device assigned to user" do
        other_device = FactoryGirl.create(:device, user: FactoryGirl.create(:user))
        create_device = described_class.new(user, developer, uuid: other_device.uuid)
        expect(create_device.save?).to be_falsey
      end

      it "returns falsey if invalid name" do
        other_device = FactoryGirl.create(:device, user: user)
        create_device = described_class.new(user, developer, name: other_device.name)
        expect(create_device.save?).to be_falsey
      end
    end

    context "error" do
      it "returns a string" do
        expect(create_device.error).to be_kind_of String
      end

      it "returns name error message by default" do
        expect(create_device.error).to match "have a device with the name"
      end

      it "returns user error message if device does not have an id" do
        other_device = FactoryGirl.create(:device, user: FactoryGirl.create(:user))
        create_device = described_class.new(user, developer, uuid: other_device.uuid)
        expect(create_device.error).to match "registered to another user"
      end

      it "returns uuid error message if device was not initialized" do
        create_device = described_class.new(user, developer, uuid: "invalid")
        expect(create_device.error).to match "UUID does not match"
      end
    end
  end
end
