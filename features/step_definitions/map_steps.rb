Given(/^I right click on the map$/) do
  find(:id, 'map').right_click
end

Given(/^I should have a new checkin$/) do
  expect(@me.checkins.count).to be > 0
end

Given(/^I click on my current location marker$/) do
  find("img[alt='currentLocation']").click
end
