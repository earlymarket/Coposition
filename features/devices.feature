@javascript
Feature: Devices

  Background: There are some devices
    Given I am signed in as a user
      And I click "Dashboard"
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"

    Scenario: User adds and views a device
      Given I click "Add new device"
        And I enter UUID "123456789123" and a friendly name "G-RALA"
      When I click "Add"
      Then I should see "This device has been bound to your account!"
        And I should see "G-RALA"
        Then I click "Dashboard"
        And I click the link "Devices"
      Then I should see "Denham"
        When I click "Denham"
      When I click "Delete device"
      Then I should see "Device deleted"
        And I should not have a device

    Scenario: User enables fogging on a device
      Given I click "Add new device"
        When I enter UUID "123456789123" and a friendly name "G-RALA"
      And I click "Add"
        Then I should see a link that says "Fog"
      When I click "Fog"
        Then I should see a link that says "Currently Fogged"
      When I click "Dashboard"
      And I click the link "Devices"
        Then I should see "Fogging is enabled"

    Scenario: User enables timeshift on a device
      Given I click "Add new device"
        When I enter UUID "123456789123" and a friendly name "G-RALA"
        And I click "Add"
        And I fill in "mins" with "10"
      When I click "Update"
        Then I should be timeshifted by "10" mins
