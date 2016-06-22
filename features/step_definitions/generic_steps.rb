Given(/^I am using a large screen$/) do
  Capybara.current_session.current_window.resize_to(1200, 800)
end

Given(/^I am on the homepage$/) do
  visit '/'
end

Given(/^I click "(.*?)"$/) do |target|
  click_on target
end

Given(/^I click the "(.*?)" link in the "(.*?)"$/) do |target, outer_selector|
  within(outer_selector) { click_link(target) }
end

Given(/^I click the link "(.*?)"$/) do |target|
  click_link(target, match: :first)
end

Then(/^I should see a link that says "(.*?)"$/) do |text|
  expect(page).to have_selector(:link_or_button, text)
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page).to have_content(text)
end

When(/^I click and confirm "([^"]*)"$/) do |target|
  page.accept_confirm do
    click_on target
  end
end

Given(/^I switch to the table view$/) do
  find('#chartTab')
  page.execute_script("$('#chartTab a').click();")
end

Given(/^I switch to the map view$/) do
  find('#mapTab')
  page.execute_script("$('#mapTab a').click();")
end
