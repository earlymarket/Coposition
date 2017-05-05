require "rails_helper"

RSpec.describe Users::Checkins::ImportCheckins, type: :interactor do
  subject(:context) { described_class.call(params: params) }

  let(:device) { create :device }
  let(:params) { { file: file, device_id: device.id } }
  let(:file) { fixture_file_upload("files/test_file.csv", "text/csv") }
  let(:invalid_file) { fixture_file_upload("files/test_file.csv", "text/pdf") }

  describe "call" do
    context "when given valid params" do
      before { allow(CSV).to receive(:foreach).and_return true }

      it "succeeds" do
        expect(context).to be_a_success
      end

      it "calls ImportWorker.perform async" do
        allow(ImportWorker).to receive(:perform_async).with(device.id)
        context
        expect(ImportWorker).to have_received(:perform_async)
      end
    end

    context "when not given a file" do
      let(:context) { described_class.call(params: { device_id: device.id }) }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "gives error message" do
        expect(context.error).to eq "You must choose a CSV file to upload"
      end
    end

    context "when given invalid file format" do
      let(:params) { { file: invalid_file, device_id: device.id } }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "gives error message" do
        expect(context.error).to eq "Invalid file format"
      end
    end

    context "when given invalid CSV" do
      before { allow(CSV).to receive(:foreach).and_return false }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "gives error message" do
        expect(context.error).to eq "Invalid file format"
      end
    end
  end
end
