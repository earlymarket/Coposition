
Given(/^there's a device in the database with the UUID "(.*?)"$/) do |uuid|
  dev = FactoryGirl::create :device
  dev.uuid = uuid
  checkin = FactoryGirl::create(:checkin)
  dev.checkins << checkin
  dev.save!
end

Given(/^I enter UUID "(.*?)" and a friendly name "(.*?)"$/) do |uuid, name|
  fill_in "device[uuid]", with: uuid
  fill_in "device[name]", with: name
end

Then(/^I should not have a device$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).devices.count).to be 0
end

Then (/^I should have a "(.*?)" device$/) do |attribute|
  expect(@me.devices.last[attribute]).to be true
end

Then (/^I should have a delayed device$/) do
  sleep 1
  expect(@me.devices.last.delayed).to eq 5
end

Given (/^I click the slider$/) do
  find(:class, '.noUi-origin').click
end
