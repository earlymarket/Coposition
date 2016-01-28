Given(/^A developer sends me an approval request$/) do
  dev = FactoryGirl::create :developer
  Approval.link(@me,dev,'Developer')
end

Then(/^I should have an approval$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).developers.count).to be 1
end

Then(/^I should not have an approval$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).developers.count).to be 0
end