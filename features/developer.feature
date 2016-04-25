Feature: Developer

@javascript
  Scenario: Developer asks user for approval
    Given I am signed in as developer
      And I click "Developers"
      And I click "users"
    Then I should see "no approvals pending"
    When I click "New approval"
      And I fill in an existing "user"'s email in the "approval_user" field
      And I click "Request"
    Then I should see "Successfully sent"
