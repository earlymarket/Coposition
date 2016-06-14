Given(/^the developer "(.*?)" exists$/) do |dev_name|
  @developer = FactoryGirl.create :developer
  @developer.company_name = dev_name
  @developer.save
end

Given(/^the developer "(.*?)" sends me an approval request$/) do |dev_name|
  @developer = Developer.find_by(company_name: dev_name)
  Approval.link(@me, @developer, 'Developer')
end

Given(/^I accept the approval request$/) do
  Approval.accept(@me, @developer, 'Developer')
end

Given(/^I click the switch "(.*?)"$/) do |target|
  find_by_id("#{@developer.id}-#{target}").click
end

Given(/^I should have "(.*?)" enabled$/) do |attribute|
  wait_until { Permission.last[attribute] == true }
end

Given(/^I should have privilege set to "(.*?)"$/) do |value|
  wait_until { Permission.last.privilege == value }
end

Given(/^I change my permissions$/) do
  steps %(
    Given I should see a link that says "lock"
      And I click the link "lock"
      And I click the switch "bypass-fogging"
      And I click the switch "bypass-delay"
      And I click the switch "last-only"
        Then I should have "bypass_fogging" enabled
        And I should have "bypass_delay" enabled
        And I should have privilege set to "last_only"
      When I click the switch "disallowed"
        Then I should have privilege set to "disallowed"
      And I click the switch "last-only"
      And I click the switch "bypass-fogging"
        Then I should have privilege set to "disallowed"
        And I should have "bypass_delay" enabled
  )
end
