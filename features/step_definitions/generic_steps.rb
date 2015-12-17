Given(/^I am on the homepage$/) do
  visit "/"
end

Given(/^I click "(.*?)"$/) do |target|
  click_on target
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page.has_content? text).to be true
end

Then(/^I should not see "(.*?)"$/) do |text|
	expect(page.has_content? text).to be false
end

Then(/^show me the page$/) do
  save_and_open_page
end
