class DeleteDeviceWorker
  include Sidekiq::Worker

  def perform(device_id)
    Checkin.where(device_id: device_id).destroy_all
  end
end
