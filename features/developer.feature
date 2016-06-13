Feature: Developer

  Background: Signed in as a developer
    Given I am signed in as developer

    @javascript
    Scenario: Developer asks user for approval
      Given I click the "Developer console" link in the "footer"
        And I click "users"
      Then I should see "no approvals pending"
      When I click the link "add"
        And I fill in an existing "user"'s email in the "approval_user" field
        And I click "Request"
      Then I should see "Successfully sent"

    @javascript
    Scenario: Developer pays and refreshes
      Given I have an unpaid request
        And I click the "Developer console" link in the "footer"
        Then I should see "1 request since"
        And I should see "1 request in"
      When I click "Pay now"
        Then I should see "0 requests since"
      When I have an unpaid request
        Then I should see "0 requests since"
      And I click "Refresh"
        Then I should see "1 request since"
        And I should see "2 requests in"
