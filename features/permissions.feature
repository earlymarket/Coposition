Feature: Permissions

  Background: There is a device and an approval
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And the developer "Wherefore Art Thou" exists
      And the developer "Wherefore Art Thou" sends me an approval request

    @javascript
    Scenario: User accepts and reviews permissions
      Given I accept the approval request
      Given I click "add"
        And I enter UUID "123456789123" and a friendly name "G-RALA"
      When I click "Add"
      Then I should see "This device has been bound to your account!"
      When I click the link "Devices"
        And I click the link "lock"
        Then I should see "Wherefore Art Thou"
      And I click the switch "bypass-fogging"
      And I click the switch "bypass-delay"
      And I click the switch "last-only"
        Then I should have "bypass_fogging" enabled
        And I should have "bypass_delay" enabled
        And I should have privilege set to "last_only"
      When I click the switch "disallowed"
        Then I should have privilege set to "disallowed"
        And I click the switch "last-only"
        And I click the switch "bypass-fogging"
        Then I should have privilege set to "disallowed"
        And I should have "bypass_delay" enabled
