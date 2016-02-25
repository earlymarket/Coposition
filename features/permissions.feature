Feature: Permissions

  Background: There is a device and an approval
    Given I am signed in as a user
      And I click "Dashboard"
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And the developer "Wherefore Art Thou" exists
      And the developer "Wherefore Art Thou" sends me an approval request

    @javascript
    Scenario: User accepts and reviews permissions
      Given I accept the approval request
      Given I click "Add new device"
        And I enter UUID "123456789123" and a friendly name "G-RALA"
      When I click "Add"
      Then I should see "This device has been bound to your account!"
        And I should see "G-RALA"
      When I click "Dashboard"
        And I click the link "Devices"
      When I click the link "Permissions"
        Then I should see "Wherefore Art Thou"
