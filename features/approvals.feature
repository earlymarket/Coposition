Feature: Approvals

  Background: A user gets sent an approval request
    Given I am signed in as a user
      And A developer sends me an approval request
      And I click "Dashboard"
      And I click "You have 1 pending approvals"

    @javascript
    Scenario: User accepts an approval
      When I click "Approve"
        Then I should have an approval
    
    @javascript
    Scenario: User rejects an approval
      When I click "Reject"
        Then I should not have an approval

