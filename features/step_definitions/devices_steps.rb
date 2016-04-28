Given(/^there's a device in the database with the UUID "(.*?)"$/) do |uuid|
  @dev = FactoryGirl::create :device
  @dev.uuid = uuid
  @dev.save!
end

Given(/^the device has checkins$/) do
  @dev.checkins << FactoryGirl::create(:checkin)
  @dev.save!
end

Given(/^I enter UUID "(.*?)" and a friendly name "(.*?)"$/) do |uuid, name|
  fill_in "device[uuid]", with: uuid
  fill_in "device[name]", with: name
end

Then(/^I should not have a device$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).devices.count).to be 0
end

Then(/^I should have a "(.*?)" device$/) do |attribute|
  sleep 0.5
  expect(@me.devices.last[attribute]).to be true
end

Then(/^I should have a delayed device$/) do
  sleep 0.5
  expect(@me.devices.last.delayed).to eq 5
end

Given(/^I click the slider$/) do
  find(:class, '.noUi-origin').click
end

Given(/^I visit my device published page$/) do
  visit "/users/#{@me.id}/devices/#{@me.devices.last.id}/shared"
end
