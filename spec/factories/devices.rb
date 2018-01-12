FactoryGirl.define do
  factory :device do
    uuid { Faker::Number.number(12) }
    name { Faker::Commerce.product_name[4..20] }
    association :user
  end
end
