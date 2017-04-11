class CheckinSerializer < ActiveModel::Serializer
  attributes :device_id, :lat, :lng
end
