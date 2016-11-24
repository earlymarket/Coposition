module CheckinsSpecHelpers
  def call_checkin_action(method, priv, delay, number, checkin)
    update_permissions(priv, delay)
    get method.to_sym, params: params
    check_response_hash(number, checkin)
  end

  def update_permissions(priv, delay)
    Device.all.each do |device|
      device.permission_for(developer).update! privilege: priv
      device.permission_for(developer).update! bypass_delay: delay
    end
  end

  def check_response_hash(number, checkin)
    expect(res_hash.size).to be number
    expect(res_hash.first['id']).to be(checkin.id) if checkin
  end
end
