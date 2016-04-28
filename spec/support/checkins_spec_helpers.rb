module CheckinsSpecHelpers

  def call_checkin_method(method, priv, delay, number, checkin)
    device.permission_for(developer).update! privilege: priv
    device.permission_for(developer).update! bypass_delay: delay
    get method.to_sym, params
    expect(res_hash.size).to be number
    expect(res_hash.first['id']).to be(checkin.id) if checkin
  end

end
