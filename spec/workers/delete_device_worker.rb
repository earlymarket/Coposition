require "rails_helper"

RSpec.describe DeleteDeviceWorker, type: :worker do
  subject(:delete) { DeleteDeviceWorker.new }
  let(:device) { create(:device) }
  let!(:checkin) { create :checkin, device: device }

  describe "perform" do
    it "pushes a job on to the queue" do
      expect { DeleteDeviceWorker.perform_async(device.id) }.to change(DeleteDeviceWorker.jobs, :size).by(1)
    end

    it "deletes the device" do
      expect { delete.perform(device.id) }.to change { Device.count }.by(-1)
    end

    it "deletes the devices checkins" do
      expect { delete.perform(device.id) }.to change { Checkin.count }.by(-1)
    end
  end
end
