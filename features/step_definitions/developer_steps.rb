Given (/^I have an unpaid request$/) do
  @developer.requests.create(action: 'last', controller: 'api/v1/users/checkins')
end
