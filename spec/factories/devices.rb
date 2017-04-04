FactoryGirl.define do
  factory :device do
    uuid { Faker::Number.number(12) }
    name { Faker::Commerce.product_name }
    association :user
  end
end
