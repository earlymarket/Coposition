FactoryGirl.define do
  factory :checkin do
    lat 51.588330
    lng (-0.513069)
    uuid { Faker::Number::number(12) }
  end

end
