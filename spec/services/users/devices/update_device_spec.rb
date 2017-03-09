require "rails_helper"

RSpec.describe Users::Devices::UpdateDevice, type: :service do
  subject(:update_service) { described_class.new(params) }

  let(:device) { FactoryGirl.create :device }
  let(:params) { { id: device.id } }

  describe "Interface" do
    %i(update_device notice device).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "public methods" do
    before do
      allow(Device).to receive(:find).and_return(device)
    end

    context "device" do
      it "returns the device specified in initializer" do
        expect(update_service.device).to be_kind_of Device
      end
    end

    context "update_device" do
      it "returns a device" do
        expect(update_service.update_device).to be_kind_of Device
      end

      it "calls device.switch_fog" do
        allow(device).to receive(:switch_fog)
        update_service.update_device
        expect(device).to have_received(:switch_fog)
      end

      it "calls update delay if delay params" do
        update_service = described_class.new(id: device.id, delayed: 10)
        allow(device).to receive(:update_delay)
        update_service.update_device
        expect(device).to have_received(:update_delay)
      end

      %i(published name cloaked icon).each do |attribute|
        it "calls update with #{attribute} param" do
          update_service = described_class.new("id" => device.id, attribute => true)
          allow(device).to receive(:update)
          update_service.update_device
          expect(device).to have_received(:update)
        end
      end
    end

    context "notice" do
      it "returns a string" do
        update_service = described_class.new(id: device.id, icon: "laptop")
        expect(update_service.notice).to be_kind_of String
      end

      it "calls humanize_delay if delay params" do
        update_service = described_class.new(id: device.id, delayed: 10)
        allow(device).to receive(:humanize_delay)
        update_service.notice
        expect(device).to have_received(:humanize_delay)
      end

      %i(published fogged cloaked).each do |attribute|
        it "calls boolean_to_state for #{attribute} param" do
          update_service = described_class.new("id" => device.id, attribute => true)
          allow(update_service).to receive(:boolean_to_state)
          update_service.notice
          expect(update_service).to have_received(:boolean_to_state)
        end
      end
    end
  end

  describe "private methods" do
    context "boolean_to_state" do
      it "returns a string" do
        expect(update_service.send(:boolean_to_state, true)).to be_kind_of String
      end

      it "returns on if true argument" do
        expect(update_service.send(:boolean_to_state, true)).to eq "on"
      end

      it "returns off if false arguments" do
        expect(update_service.send(:boolean_to_state, false)).to eq "off"
      end
    end
  end
end
