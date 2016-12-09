@javascript
Feature: Approvals

  Background: A user gets sent approval requests
    Given I am signed in as a user
      And A developer sends me an approval request
      And A user sends me a friend request
      And I click the link "Apps"

    Scenario: User accepts requests
      When I click "Revoke Approval"
      And I click "Approve"
        Then I should see an approved app
      And I click the link "Friends"
        Then I should see an approval request
      When I click "Approve"
        Then I should see an approved friend

    Scenario: User rejects requests
      When I click "Reject"
        Then I should not see any approval requests
      And I click "Revoke Approval"
        Then I should not see any approved apps
      And I click the link "Friends"
      When I click "Reject"
        Then I should not see any approved friends
