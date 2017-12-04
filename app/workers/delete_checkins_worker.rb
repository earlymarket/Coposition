class DeleteCheckinsWorker
  include Sidekiq::Worker

  def perform(device_id)
    device = Device.find(device_id)
    device.checkins.destroy_all
    device.destroy
  end
end
