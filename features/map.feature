Feature: map

  Background: There are some devices
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And I click "add"
      And I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"

    @javascript
    Scenario: User creates a new checkin
      When I right click on the map
      And I click "Create checkin here"
        Then I should have a new checkin
