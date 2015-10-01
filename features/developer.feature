Feature: Developer

  Scenario: Developer login
    Given I am on the homepage
      And I click "Developers"
      And I click "Sign up"
    When I fill in the form with my "developer" details
      And I click "Sign up"
    Then I should see "You have signed up successfully."

