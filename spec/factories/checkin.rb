FactoryGirl.define do
  factory :checkin do
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
    uuid { Faker::Number::number(12) }
  end

end
