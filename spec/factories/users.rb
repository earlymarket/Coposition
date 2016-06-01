FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name(nil, %w(_ -)) }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
  end
end
