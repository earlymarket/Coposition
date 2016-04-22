Given(/^I am using a large screen$/) do
  Capybara.current_session.driver.browser.manage.window.resize_to(1200, 800)
end

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

Given(/^I confirm$/) do
  a = page.driver.browser.switch_to.alert
  a.accept
end

Given(/^I right click on the "(.*?)"$/) do |target|
  find(:id, target).right_click
end

Given(/^I click on the "(.*?)"$/) do |target|
  find(:id, target).click
end
