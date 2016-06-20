Feature: chart

  Background: There are some devices
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And the device has checkins
      And I click "add"
      And I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"
      And I switch to the table view
      Then I should have 1 checkins in the table

    @javascript
    Scenario: User fogs a checkin
      When I click the link "cloud"
      Then I should have a fogged last checkin

    @javascript
    Scenario: User deletes a checkin
    When I click and confirm "delete_forever"
      Then I should have 0 checkins in the table
    And I click "Map"
      Then I should have 0 checkins on the map
