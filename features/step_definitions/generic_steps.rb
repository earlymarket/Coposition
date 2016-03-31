Given(/^I am on the homepage$/) do
  visit "/"
end

Given(/^I click "(.*?)"$/) do |target|
  click_on target
end

Given(/^I click the link "(.*?)"$/) do |target|
  if target == 'login'
    Capybara.current_session.driver.browser.manage.window.resize_to(1200, 800)
  end
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
