Given(/^I right click on the map$/) do
  find('#map').right_click
  expect(page).to have_content('Create checkin here')
end
