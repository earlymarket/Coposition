Feature: Developer

  Background: Signed in as a developer
    Given I am signed in as developer

    @javascript
    Scenario: Developer asks user for approval
      Given I click "Developers"
        And I click "users"
      Then I should see "no approvals pending"
      When I click "New user"
        And I fill in an existing "user"'s email in the "approval_user" field
        And I click "Request"
      Then I should see "Successfully sent"

    @javascript
    Scenario: Developer pays
      Given I have an unpaid request
        And I click "Developers"
        Then I should see "1 requests"
      When I click "Pay now"
        Then I should see "0 requests"
