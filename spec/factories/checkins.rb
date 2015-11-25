# FactoryGirl.define do
#   factory :redbox_checkin do
#     status "A"
#     lat { Faker::Address.latitude }
#     n_s { ["N", "S"].shuffle.first }
#     lng { Faker::Address.longitude }
#     e_w { ["E", "W"].shuffle.first }
#     gspeed { Faker::Number.between(0, 130) + (Faker::Number.between(0, 99) / 100) }
#     altitude { Faker::Number.between(0, 8000) + (Faker::Number.between(0, 99) / 100) }
#     course { Faker::Number.between(0, 359) + (Faker::Number.between(0, 99) / 100) }
#     time { Time.now.strftime("%H%M%S.%L") }
#     date { Time.now.strftime("%d%m%y") }
#     rotorspeed { Faker::Number.between(0, 600) + (Faker::Number.between(0, 99) / 100) }
#     enginespeed { Faker::Number.between(0, 3000) + (Faker::Number.between(0, 99) / 100) }
#   end

# end
