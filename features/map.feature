Feature: map

  Background: There are some devices
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And I click "add"
      And I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"

    @javascript
    Scenario: User creates and fogs checkin
      When I right click on the map
      And I click "Create checkin here"
        Then I should have a new checkin
      And I click on the map
      And I click on my last checkin
        When I click the link "cloud"
      Then I should have a fogged last checkin
      And I click the link "delete_forever"
      And I confirm
        Then I should have one less checkin
