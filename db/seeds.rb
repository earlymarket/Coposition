# Setup user/dev for example site
developer = FactoryGirl.build :developer
developer.company_name = 'Demo developer account'
developer.api_key = Rails.application.secrets['mobile_app_api_key']
developer.save!

user = FactoryGirl.build :user
user.username = 'coporulez'
user.save!

device = FactoryGirl.create :device
user.devices << device
user.save!

device.checkins.create(lat: 51.588330, lng: -0.513069)
device.save!
