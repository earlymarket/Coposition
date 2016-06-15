Feature: Permissions

  Background: There is an approved device
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And the developer "Wherefore Art Thou" exists
      And the developer "Wherefore Art Thou" sends me an approval request
      And I accept the approval request
      And I click "add"
      And I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"

    @javascript
    Scenario: User reviews and changes permissions
      Given I click the link "Apps"
      When I click the link "lock"
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


    @javascript
    Scenario: User reviews and changes permissions from the devices page
      Given I click the link "Devices"
      When I click the link "lock"
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
