FactoryBoy.define do
  factory :checkin do
    lat 51.588330
    lng(-0.513069)
    speed 0
    altitude 0
    association :device
  end
end
