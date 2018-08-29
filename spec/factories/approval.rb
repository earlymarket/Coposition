FactoryBoy.define do
  factory :approval do
    status 'pending'
    association :user
    association :approvable, factory: :user
  end
end
