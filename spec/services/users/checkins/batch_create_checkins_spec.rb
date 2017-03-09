require "rails_helper"

RSpec.describe Users::Checkins::BatchCreateCheckins, type: :service do
  subject(:batch_create) { described_class.new(device, post_content) }

  let(:post_content) do
    [{ lat: "50.588330", lng: "-0.513069" }, { lat: "51.588330", lng: "-1.513069" }].to_json
  end
  let(:device) { FactoryGirl.create :device, user: user }
  let(:user) { FactoryGirl.create :user }

  describe "Interface" do
    it { is_expected.to respond_to :success }
    it { is_expected.to respond_to :device }
  end

  describe "public methods" do
    context "device" do
      it "returns the device specified in initializer" do
        expect(batch_create.device).to eq device
      end
    end

    context "success" do
      it "calls Checkin.transaction" do
        allow(Checkin).to receive(:transaction)
        batch_create.success
        expect(Checkin).to have_received(:transaction)
      end

      it "calls checkin_create" do
        allow(batch_create).to receive(:checkin_create).and_return(Checkin.new)
        batch_create.success
        expect(batch_create).to have_received(:checkin_create).twice
      end

      it "calls Checkin.import" do
        allow(Checkin).to receive(:import)
        batch_create.success
        expect(Checkin).to have_received(:import)
      end

      it "returns falsey if invalid post_content" do
        expect(described_class.new(device, [{ lat: 10 }].to_json).success).to be_falsey
      end
    end
  end

  describe "private methods" do
    context "checkin_create" do
      let(:new_hash) { { "lat" => 10, "lng" => 10, "device_id" => device.id } }

      it "calls Checkin.new" do
        allow(Checkin).to receive(:new).and_return(Checkin.new(new_hash))
        batch_create.send(:checkin_create, new_hash)
        expect(Checkin).to have_received(:new)
      end

      it "calls hash.slice" do
        allow(new_hash).to receive(:slice).and_return(new_hash)
        batch_create.send(:checkin_create, new_hash)
        expect(new_hash).to have_received(:slice)
      end

      it "calls valid_hash" do
        allow(new_hash).to receive(:slice).and_return(new_hash)
        allow(batch_create).to receive(:valid_hash).and_return(true)
        batch_create.send(:checkin_create, new_hash)
        expect(batch_create).to have_received(:valid_hash)
      end

      it "calls assign_values" do
        checkin = Checkin.new(new_hash)
        allow(Checkin).to receive(:new).and_return(checkin)
        allow(checkin).to receive(:assign_values).and_return(checkin)
        batch_create.send(:checkin_create, new_hash)
        expect(checkin).to have_received(:assign_values)
      end

      it "raises ActiveRecord::Rollback if not valid hash" do
        expect { batch_create.send(:checkin_create, "lat" => 1) }.to raise_error(ActiveRecord::Rollback)
      end

      it "returns a new checkin" do
        allow(new_hash).to receive(:slice).and_return(new_hash)
        expect(batch_create.send(:checkin_create, new_hash)).to be_kind_of Checkin
      end
    end

    context "valid_hash" do
      it "returns false if checkin doesn't have lat and lng" do
        expect(batch_create.send(:valid_hash, Checkin.new)).to eq false
      end

      it "returns true if checkin has lat and lng" do
        expect(batch_create.send(:valid_hash, Checkin.new(lat: 10, lng: 10))).to eq true
      end
    end
  end
end
