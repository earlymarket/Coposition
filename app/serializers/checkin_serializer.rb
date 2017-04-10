class CheckinSerializer < ActiveModel::Serializer
  attributes :uuid, :device_id, :lat, :lng
end
