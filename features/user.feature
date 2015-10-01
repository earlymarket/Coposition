Feature: User  

  Background: A user gets sent an approval request
    Given I am signed in as a user
      And A developer sends me an approval request

    @javascript
    Scenario: User accepts an approval
      Given I click "Dashboard"
        And I click "You have 1 pending approvals"
      When I click "Approve"
        Then I should have an approval