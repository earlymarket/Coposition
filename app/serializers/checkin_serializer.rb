class CheckinSerializer < ActiveModel::Serializer
  attributes :id, :device_id, :lat, :lng, :address, :city, :postal_code,
    :created_at, :updated_at, :country_code
end
