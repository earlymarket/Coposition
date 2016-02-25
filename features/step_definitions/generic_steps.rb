Given(/^I am on the homepage$/) do
  visit "/"
end

Given(/^I click "(.*?)"$/) do |target|
  click_on target
end

Given(/^I click the link "(.*?)"$/) do |target|
  click_link(target, match: :first)
end

Then(/^I should see a link that says "(.*?)"$/) do |text|
  expect(page.has_link? text).to be true
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page.has_content? text).to be true
end
