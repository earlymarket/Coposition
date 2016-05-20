FactoryGirl.define do
  factory :subscription do
    target_url { "http://#{Faker::Internet.domain_word}.#{Faker::Internet.domain_suffix}/" }
    event "New checkin"
  end
end
