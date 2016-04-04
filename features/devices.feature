@javascript
Feature: Devices

  Background: There are some devices
    Given I am signed in as a user
      And I click the link "Devices"
      And there's a device in the database with the UUID "123456789123"

    Scenario: User adds and views a device
      Given I click "Add new device"
        And I enter UUID "123456789123" and a friendly name "G-RALA"
      When I click "Add"
      Then I should see "This device has been bound to your account!"
        # And I should see "G-RALA"
        And I click the link "Devices"
      Then I should see "Denham"
        When I click "Denham"
      When I click "Delete device"
      And I confirm
      Then I should see "Device deleted"
        And I should not have a device

     Scenario: User changes privacy settings on a device
        Given I click "Add new device"
          When I enter UUID "123456789123" and a friendly name "G-RALA"
        And I click "Add"
        And I click the link "Devices"
        And I click the link "Privacy"
          Then I should see a link that says "cloud_off"
        When I click the link "cloud_off"
          Then I should see a link that says "cloud_done"
          And I fill in "mins" with "10"
        When I click "Update"
         Then I should be timeshifted by "10" mins
        When I click the link "visibility_off"
          Then I should see a link that says "last location"
          And I should see a link that says "visibility"
