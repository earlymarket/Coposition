require "rails_helper"

RSpec.describe Users::Devices::CreateDevice, type: :interactor do
  subject(:create_context) { described_class.call(user: user, developer: developer, params: params) }

  let(:user) { create :user }
  let(:developer) { create :developer }
  let(:device) { create :device, user: nil }
  let(:params) do
    ActionController::Parameters.new(
      device: { name: "laptop", icon: "laptop", uuid: device.uuid, location: "51.5,-0.21" }
    )
  end

  describe "call" do
    context "when given valid params" do
      it "succeeds" do
        expect(create_context).to be_a_success
      end

      it "provides the new device" do
        expect(create_context.device).to eq device
      end

      it "provides a new checkin" do
        expect(create_context.checkin).to eq device.checkins.first
      end
    end

    context "when given invalid uuid" do
      let(:params) do
        ActionController::Parameters.new(
          device: { name: "laptop", icon: "laptop", uuid: "invalid", location: "51.5,-0.21" }
        )
      end

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides a helpful error message" do
        expect(create_context.error).to eq "UUID does not match an existing device"
      end
    end

    context "when given a taken device name" do
      before do
        create(:device, name: "laptop", user: user)
      end

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides a helpful error message" do
        expect(create_context.error).to eq "You already have a device with the name laptop"
      end
    end

    context "when given a device assigned to another user" do
      before do
        device.update(user: create(:user))
      end

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides a helpful error message" do
        expect(create_context.error).to eq "Device is registered to another user"
      end
    end
  end
end
