require "rails_helper"

RSpec.describe ImportWorker, type: :worker do
  subject(:import) { ImportWorker.new }
  let(:device) { create(:device, csv: File.open(file.path, "r")) }
  let(:file) { fixture_file_upload("files/test_file.csv", "text/csv") }
  let(:checkin) { create :checkin, device: device }
  let(:params) { { "lat" => 10, "lng" => 10, "speed" => 10, "altitude" => 10 } }

  describe "perform" do
    it "pushes a job on to the queue" do
      expect { ImportWorker.perform_async(device.id) }.to change(ImportWorker.jobs, :size).by(1)
    end

    it "calls checkin_create_or_update_from_row" do
      allow(import).to receive(:checkin_create_or_update_from_row!)
      import.perform(device.id)
      expect(import).to have_received(:checkin_create_or_update_from_row!).twice
    end
  end

  describe "checkin_create_or_update_from_row!" do
    it "creates a new checkin" do
      expect do
        import.checkin_create_or_update_from_row!(params, device.id)
      end.to change { Checkin.count }.by 1
    end

    it "updates an existing checkin" do
      expect do
        import.checkin_create_or_update_from_row!(params.merge("id" => checkin.id), device.id)
      end.to change { Checkin.find(checkin.id).lat }.to 10
    end
  end

  describe "attributes from row" do
    it "extracts checkin attributes from CSV row" do
      expect(import.attributes_from_row(params)).to eq(params)
    end
  end
end
