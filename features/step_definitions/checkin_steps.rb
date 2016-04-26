Then(/^I have "(.*?)" checkins on the map$/) do |number|
  sleep 0.5
  expect(all("img.leaflet-marker-icon").size).to be number.to_i
  expect(@me.checkins.count).to be number.to_i
end

Then(/^I have "(.*?)" checkins in the table$/) do |number|
  sleep 0.5
  # +1 as the table headers count as another tr
  expect(all("tr").size).to be number.to_i+1
  expect(@me.checkins.count).to be number.to_i
end

Given(/^I click on my last checkin$/) do
  find("img[alt='lastCheckin']").click
end

Then(/^I should have a fogged last checkin$/) do
  sleep 0.5
  expect(@me.checkins.first.fogged).to be true
end
