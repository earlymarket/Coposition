Given(/^A developer sends me an approval request$/) do
  dev = FactoryGirl::create :developer
  dev.request_approval_from User.find_by_email(@me.email)
end

Then(/^I should have an approval$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).approved_developers.count).to be 1
end
