class CheckinSerializer < ActiveModel::Serializer
  attributes :id, :device_id, :lat, :lng, :address, :city, :fogged_city, :postal_code,
    :created_at, :updated_at
end
