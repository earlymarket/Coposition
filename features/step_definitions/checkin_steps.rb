Given (/^I have a checkin on the map$/) do
  expect(all("img.leaflet-marker-icon").size).to be @me.checkins.count
  @count = @me.checkins.count
end

Given(/^I should have a new checkin on the map$/) do
  sleep 0.5
  expect(all("img.leaflet-marker-icon").size).to be (@count+1)
  expect(@me.checkins.count).to be (@count+1)
  @count = @me.checkins.count
end

Given(/^I should have one less checkin on the map$/) do
  sleep 1
  expect(all("img.leaflet-marker-icon").size).to be @count-1
  expect(@me.checkins.count).to be @count-1
  @count = @me.checkins.count
end

Given (/^I have a checkin in the table$/) do
  expect(all("tr").size).to be @me.checkins.count+1
  @count = @me.checkins.count
end

Given(/^I should have a new checkin in the table$/) do
  sleep 0.5
  expect(all("tr").size).to be (@count+1)
  expect(@me.checkins.count).to be (@count)
  @count = @me.checkins.count
end

Given(/^I should have one less checkin in the table$/) do
  sleep 0.5
  expect(all("tr").size).to be @count
  expect(@me.checkins.count).to be @count-1
  @count = @me.checkins.count
end

Given(/^I click on my last checkin$/) do
  find("img[alt='lastCheckin']").click
end

Given(/^I should have a fogged last checkin$/) do
  sleep 0.5
  expect(@me.checkins.first.fogged).to be true
end
