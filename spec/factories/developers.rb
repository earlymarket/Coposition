FactoryGirl.define do
  factory :developer do
    company_name { Faker::Company.name }
    email { Faker::Internet.email }
    password "password"
    password_confirmation "password"
  end

end
