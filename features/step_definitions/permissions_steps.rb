Given(/^the developer "(.*?)" exists$/) do |dev_name|
  @developer = FactoryGirl::create :developer
  @developer.company_name = dev_name
  @developer.save
end

Given(/^the developer "(.*?)" sends me an approval request$/) do |dev_name|
  @developer = Developer.find_by(company_name: dev_name)
  Approval.link(@me,@developer,'Developer')
end

Given(/^I accept the approval request$/) do
  Approval.accept(@me,@developer,'Developer')
end
