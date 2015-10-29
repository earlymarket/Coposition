Given(/^I am signed in as developer$/) do
  steps %Q{
    Given I am on the homepage
      And I click "Developers"
    When I fill in the form with my "developer" details
      And I click "Sign up"
    Then I should see "You have signed up successfully."
  }
end

Given(/^I am signed in as a user$/) do
  steps %Q{
    Given I am on the homepage
      And I click "Sign in"
    When I fill in the form with my "user" details
      And I click "Sign up"
    Then I should see "You have signed up successfully."
  }
  @me = User.find_by(email: @me.email)
end

When(/^I fill in the form with my "(.*?)" details$/) do |actor|
  @me = FactoryGirl::build actor.to_sym
  if actor == "developer"
    fill_in "register_#{actor}_company_name", with: @me.company_name
  elsif actor == "user"
    fill_in "register_#{actor}_username", with: @me.username
  end
  fill_in "register_#{actor}_email", with: @me.email
  fill_in "register_#{actor}_password", with: @me.password
  fill_in "register_#{actor}_password_confirmation", with: @me.password_confirmation
end

When(/^I fill in an existing "(.*?)"'s email in the "(.*?)" field$/) do |actor, field|
  actor = FactoryGirl::create actor.to_sym
  fill_in field, with: actor.email
end
