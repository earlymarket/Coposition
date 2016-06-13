Feature: Sign up and log in

@javascript
  Scenario: Developer login
    Given I am on the homepage
      And I click the "Developer log in" link in the "footer"
      Then I click the link "Sign up!"
    When I fill in the form with my "developer" details
      And I click "Sign up"
    Then I should see "You have signed up successfully."

@javascript
  Scenario: User login
    Given I am using a large screen
    And I am on the homepage
      And I click the link "User Log In"
      Then I click the link "Sign up!"
    When I fill in the form with my "user" details
      And I click "Sign up"
    Then I should see "Enter a name for the device"
