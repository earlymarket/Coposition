FactoryBoy.define do
  factory :email_request do
    email { Faker::Internet.email }
    association :user
  end
end
