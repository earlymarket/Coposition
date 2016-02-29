Given(/^A developer sends me an approval request$/) do
  dev = FactoryGirl::create :developer
  Approval.link(@me,dev,'Developer')
end

Given(/^A user sends me a friend request$/) do
  user = FactoryGirl::create :user
  Approval.link(user,@me,'User')
end

Then(/^I should have an application$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).developers.count).to be 1
end

Then(/^I should have a friend$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).friends.count).to be 1
end

Then(/^I should not have any applications$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).developers.count).to be 0
end

Then(/^I should not have any friends$/) do
  sleep 0.5
  expect(User.find_by_email(@me.email).friends.count).to be 0
end
