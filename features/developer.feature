Feature: Developer

@javascript
  Scenario: Developer asks user for approval
    Given I am using a large screen
    Given I am signed in as developer
      And I click "Developers"
      And I click "approvals"
    Then I should see "0 pending"
    When I click "New approval"
      And I fill in an existing "user"'s email in the "approval_user" field
      And I click "Request"
    Then I should see "Successfully sent"
