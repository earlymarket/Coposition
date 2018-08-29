FactoryBoy.define do
  factory :activity, class: PublicActivity::Activity do |f|
    f.trackable_type "Device"
    f.trackable_id 1
    f.owner_type "User"
    f.owner_id 1
    f.key "device.update"
  end
end
