FactoryGirl.define do
  factory :device do
    uuid { Faker::Number.number(12) }
    name { Faker::Internet.unique.user_name(4..20, %w[_]) }
    association :user
  end
end
