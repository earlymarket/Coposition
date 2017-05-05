require "rails_helper"

RSpec.describe Users::Devices::UpdateDevice, type: :interactor do
  subject(:update_context) { described_class.call(params: params) }

  let(:device) { create :device }
  let(:params) { ActionController::Parameters.new(id: device.id, device: { fogged: false }) }

  describe "call" do
    context "with valid fogging params" do
      it "succeeds" do
        expect(update_context).to be_a_success
      end

      it "provides the device" do
        expect(update_context.device).to eq device
      end

      it "provides a helpful notice" do
        expect(update_context.notice).to eq "Location fogging is off."
      end
    end

    context "with valid delay params" do
      let(:params) { ActionController::Parameters.new(id: device.id, delayed: 10) }

      it "succeeds" do
        expect(update_context).to be_a_success
      end

      it "provides a helpful notice" do
        expect(update_context.notice).to eq "#{device.name} delayed by 10 minutes."
      end
    end

    context "with valid published params" do
      let(:params) { ActionController::Parameters.new(id: device.id, device: { published: true }) }

      it "succeeds" do
        expect(update_context).to be_a_success
      end

      it "provides a helpful notice" do
        expect(update_context.notice).to eq "Location sharing is on."
      end
    end

    context "with valid icon params" do
      let(:params) { ActionController::Parameters.new(id: device.id, device: { icon: "mobile" }) }

      it "succeeds" do
        expect(update_context).to be_a_success
      end

      it "provides a helpful notice" do
        expect(update_context.notice).to eq "Device icon updated"
      end
    end

    context "with valid cloaked params" do
      let(:params) { ActionController::Parameters.new(id: device.id, device: { cloaked: true }) }

      it "succeeds" do
        expect(update_context).to be_a_success
      end

      it "provides a helpful notice" do
        expect(update_context.notice).to eq "Device cloaking is on."
      end
    end

    context "with invalid params" do
      let(:params) do
        create(:device, name: "laptop", user: device.user)
        ActionController::Parameters.new(id: device.id, device: { name: "laptop" })
      end

      it "fails" do
        expect(update_context).to be_a_failure
      end

      it "provides a helpful error" do
        expect(update_context.error).to eq name: ["has already been taken"]
      end
    end
  end
end
