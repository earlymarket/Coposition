FactoryGirl.define do
  factory :checkin do
    lat 51.588330
    lng(-0.513069)
    association :device
  end
end
