FactoryBot.define do
  factory :subscription do
    target_url { "http://#{Faker::Internet.domain_word}.#{Faker::Internet.domain_suffix}/" }
    event { 'new_checkin' }
  end
end
