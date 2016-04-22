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
        Then I change my permissions

    @javascript
    Scenario: User reviews and changes permissions from the devices page
      Given I click the link "Devices"
        Then I change my permissions
