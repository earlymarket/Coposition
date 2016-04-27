Feature: chart

  Background: There are some devices
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And the device has checkins
      And I click "add"
      And I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"
      And I click on the "chartTab"

    @javascript
    Scenario: User fogs and deletes a checkin
    Given I have "1" checkins in the table
      When I click the link "cloud"
      Then I should have a fogged last checkin
    When I click the link "delete_forever"
    And I confirm
      Then I have "0" checkins in the table
    And I click "Map"
      Then I have "0" checkins on the map
