Then(/^I(?: should)? have (\d+) checkins on the map$/) do |number|
  page.has_selector?('img.leaflet-marker-icon', count: number.to_i)
end

Then(/^I(?: should)? have (\d+) checkins in the table$/) do |number|
  wait_until { page.has_selector?('tr', count: number.to_i + 1) }
end

Given(/^I click on my last checkin$/) do
  find("img[alt='lastCheckin']").click
end

Then(/^I should have a fogged last checkin$/) do
  expect(page).to have_selector('a.enabled-icon', count: 1)
end
