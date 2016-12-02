Given(/^A developer sends me an approval request$/) do
  dev = FactoryGirl.create :developer
  Approval.link(@me, dev, 'Developer')
end

Given(/^A user sends me a friend request$/) do
  user = FactoryGirl.create :user
  Approval.link(user, @me, 'User')
end

Then(/^I should have an approved (?:app|friend)$/) do
  expect(page).to have_selector('div.card-panel', count: 1)
end

Then(/^I should not have any approved (?:apps|friends)$/) do
  expect(page).to have_selector('div.card-panel', count: 0)
end

Then(/^I should not have any approval requests$/) do
  expect(page).to have_select('div.collection-item', count: 0)
end
