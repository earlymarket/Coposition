When(/^I fill in the form with my "(.*?)" details$/) do |actor|
  me = FactoryGirl::build actor.to_sym
  if actor == "developer"
    fill_in "Company name", with: me.company_name
  elsif actor == "user"
    fill_in "Username", with: me.username
  end
  fill_in "Email", with: me.email
  fill_in "Password", with: me.password
  fill_in "Password confirmation", with: me.password_confirmation
end
