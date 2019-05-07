FactoryBot.define do
  factory :permission do
    privilege { 0 }
    association :device
    association :permissible, factory: :user
  end
end
