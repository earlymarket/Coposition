FactoryGirl.define do
  factory :request do
    developer { FactoryGirl.create :developer }
  end
end
