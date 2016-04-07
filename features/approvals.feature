@javascript
Feature: Approvals

  Background: A user gets sent approval requests
    Given I am using a large screen
    Given I am signed in as a user
      And A developer sends me an approval request
      And A user sends me a friend request
      And I click "Apps"

    Scenario: User accepts requests
      When I click "Approve"
        Then I should have an app
      And I click "Friends"
      When I click "Approve"
        Then I should have a friend

    Scenario: User rejects requests
      When I click "Reject"
        Then I should not have any apps
      And I click "Friends"
      When I click "Reject"
        Then I should not have any friends
