FactoryGirl.define do
  factory :user do
    username { Faker::Internet.unique.user_name(4..20, %w(_ -)) }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
  end
end
