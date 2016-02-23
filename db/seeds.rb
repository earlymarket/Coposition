
# Setup user/dev for example site
user = FactoryGirl::build :user
user.username = "coporulez"
user.save!

device = FactoryGirl::create :device
user.devices << device
user.save!

checkin = FactoryGirl::create :checkin
device.checkins << checkin
device.save!

developer = FactoryGirl::build :developer
developer.save!
developer.company_name = "Demo developer account"
developer.save!
