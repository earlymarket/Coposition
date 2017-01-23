Given(/^there's a device in the database with the UUID "(.*?)"$/) do |uuid|
  @dev = FactoryGirl.create :device
  @dev.uuid = uuid
  @dev.save!
end

Given(/^the device has checkins$/) do
  @dev.checkins << FactoryGirl.create(:checkin)
  @dev.save!
end

Given(/^I enter UUID "(.*?)" and a friendly name "(.*?)"$/) do |uuid, device_name|
  sleep 1
  fill_in 'device_uuid', with: uuid
  fill_in 'device_name', with: device_name
end

Then(/^I should have a device$/) do
  expect(page).to have_selector('div.card-panel', count: 1)
end

Then(/^I should not have a device$/) do
  expect(page).not_to have_selector('div.card-panel')
end

Then(/^I should have an unfogged device$/) do
  expect(page).to have_selector('a[data-tooltip="Fogging"] i.disabled-icon', count: 1)
end

Then(/^I should have a published device$/) do
  expect(page).not_to have_selector('a[data-tooltip="Device sharing"] i.disabled-icon')
end

Then(/^I should have a cloaked device$/) do
  expect(page).not_to have_selector('a[data-tooltip="Cloaking"] i.disabled-icon-simple')
end

Then(/^I should have a delayed device$/) do
  expect(page).not_to have_selector('a.modal-trigger i.disabled-icon')
end

Given(/^I click the slider$/) do
  find(:class, '.noUi-origin').click
end

Given(/^I visit my device published page$/) do
  visit "/users/#{@me.id}/devices/#{@me.devices.last.id}/shared"
end
