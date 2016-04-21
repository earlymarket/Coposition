Given(/^I right click on the map$/) do
  find(:id, 'map').right_click
end

Given(/^I click on the map$/) do
  find(:id, 'map').click
end

Given(/^I should have a new checkin$/) do
  sleep 0.5
  expect(@me.checkins.count).to be 2
end

Given(/^I click on my last checkin$/) do
  find("img[alt='lastCheckin']").click
end

Given(/^I should have a fogged last checkin$/) do
  sleep 0.5
  expect(@me.checkins.first.fogged).to be true
end

Given(/^I should have one less checkin$/) do
  sleep 0.5
  expect(@me.checkins.count).to be 1
end
