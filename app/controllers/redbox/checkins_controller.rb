class Redbox::CheckinsController < CheckinsController

  @@model = RedboxCheckin

  # Should only ever be called from the RedBox device
  def create
    RedboxCheckin.create_from_string(request.body.read)
    render text: "ok"
  end

  # Should only be enabled during initial development
  def create_spoofs
    device = Device.create
    device.uuid = params[:uuid]
    device.save
    RedboxCheckin.transaction do
      50.times do
        RedboxCheckin.create_from_string(RequestFixture.new(params[:uuid]).w_gps)
      end
    end
    redirect_to user_devices_path(current_user)
  end

end