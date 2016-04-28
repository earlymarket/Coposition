module CheckinsSpecHelpers

  def call_last(priv, delay, params, number, checkin)
    device.permission_for(developer).update! privilege: priv
    device.permission_for(developer).update! bypass_delay: delay
    get :last, params
    expect(res_hash.size).to be number
    expect(res_hash.first['id']).to be(checkin.id) if checkin
  end

end
