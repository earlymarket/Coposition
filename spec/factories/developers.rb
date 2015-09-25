FactoryGirl.define do
  factory :developer do
    email { Faker::Internet.email }
    password "password"
    password_confirmation "password"
  end

end
