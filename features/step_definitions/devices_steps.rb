
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

When(/^I fill in "(.*?)" with "(.*?)"$/) do |input, mins|
  fill_in input, with: mins
end

Then(/^I should be timeshifted by "(.*?)" mins$/) do |mins|
  sleep 0.5
  expect(page.has_content? "timeshifted by #{mins} minutes").to be true
end

Then(/^I should not have a device$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).devices.count).to be 0
end
