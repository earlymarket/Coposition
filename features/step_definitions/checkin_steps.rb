Then(/^I have "(.*?)" checkins on the map$/) do |number|
  expect(page).to have_selector("img.leaflet-marker-icon", count: number.to_i)
end

Then(/^I have "(.*?)" checkins in the table$/) do |number|
  # +1 as the table headers count as another tr
  expect(page).to have_selector("tr", count: number.to_i+1)
end

Given(/^I click on my last checkin$/) do
  find("img[alt='lastCheckin']").click
end

Then(/^I should have a fogged last checkin$/) do
  sleep 0.5
  expect(@me.checkins.first.fogged).to be true
end
