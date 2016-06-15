Given(/^I right click on the map when it's ready$/) do
  begin
    start_time ||= Time.now
    find(:id, 'map').right_click
    expect(page).to have_content('Create checkin here')
  rescue RSpec::Expectations::ExpectationNotMetError
    retry if Time.now - start_time < Capybara.default_max_wait_time
    raise RSpec::Expectations::ExpectationNotMetError
  end
end
