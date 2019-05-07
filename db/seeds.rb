# Setup user/dev for example site
developer = FactoryBot.build :developer
developer.company_name = 'Mobile Coposition'
developer.api_key = Rails.application.secrets[:mobile_app_api_key]
developer.save!

developer = FactoryBot.build :developer
developer.company_name = 'Coposition'
developer.api_key = Rails.application.secrets[:coposition_api_key]
developer.save!

user = FactoryBot.build :user
user.username = 'coporulez'
user.save!

device = FactoryBot.create :device
user.devices << device
user.save!

device.checkins.create(lat: 51.588330, lng: -0.513069)
device.save!

User.create!(
  username: "admin_user",
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  admin: true
)
