Feature: Developer

  Scenario: Developer login
    Given I am on the homepage
      And I click "Developers"
      And I click "Sign up"
    When I fill in the form with my "developer" details
      And I click "Sign up"
    Then I should see "You have signed up successfully."

  Scenario: Developer asks user for approval
    Given I am signed in as developer
      And I click "Developers"
      And I click "approvals"
    Then I should see "0 pending"
    When I click "New approval"
      And I fill in an existing "user"'s email in the "approval_user" field
      And I click "Request"
    Then I should see "Successfully sent"
      And I click "Sign out"
