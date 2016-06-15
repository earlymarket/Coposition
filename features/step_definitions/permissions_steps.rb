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
  switch = find(:id, "#{@developer.id}-#{target}")
  switch.click
  checkbox = if target == 'bypass-delay'
               find(:id, 'bypass_delay', match: :first)
             elsif target == 'bypass-fogging'
               find(:id, 'bypass_fogging', match: :first)
             elsif target == 'last-only'
               find(:id, 'last_only', match: :first)
             else
               find(:id, 'privilege', match: :first)
             end
  switch.click unless checkbox.checked?
end

Given(/^I should have "(.*?)" enabled$/) do |attribute|
  wait_until { Permission.last[attribute] == true }
end

Given(/^I should have privilege set to "(.*?)"$/) do |value|
  wait_until { Permission.last.privilege == value }
end
