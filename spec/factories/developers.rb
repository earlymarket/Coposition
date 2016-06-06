FactoryGirl.define do
  factory :developer do
    company_name { Faker::Company.name }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    redirect_url { "http://#{Faker::Internet.domain_word}.#{Faker::Internet.domain_suffix}/" }
  end
end
