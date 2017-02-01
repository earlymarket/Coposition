Feature: map

  Background: There are some devices
    Given I am signed in as a user
      And I am using a large screen
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"
      And I click "add"
      And I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"

    @javascript
    Scenario: User creates and fogs checkin
    Given I have 0 checkins on the map
      When I right click on the map
      And I click "Create checkin here"
        Then I have 1 checkins on the map
      When I click "Checkin now"
        Then I have 2 checkins on the map
      And I click on my last checkin
        When I click the link "cloud"
      Then I should have a fogged last checkin
      And I click and confirm "delete_forever"
        Then I have 0 checkins on the map

    @javascript
    Scenario: User views their published page
      Given I right click on the map
        And I click "Create checkin here"
      When I click the link "Devices"
        And I click the link "public"
      When I visit my device published page
       Then I have 1 checkins on the map
