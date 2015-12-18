Feature: Pricing
  As the site owner
  I want to charge developers for making API requests
  API requests should not be fulfilled unless a developer has credits
  Credits should be added and managed from the developer console

  Background:
    Given I am on the homepage
    I sign in as a developer using "gary@gary.com"
    And I click "Developers"

  Scenario Outline: an app makes some API calls while in credit
    Given there are <start> credits
    When my app makes <number> API calls
    Then there should be <end> credits

  Examples:
    | start | number | end |
    | 10    | 3      | 7   |
    | 10    | 5      | 5   |
    | 12    | 5      | 7   |
    | 20    | 2      | 18  |

  Scenario: a developer runs out of credits
    Given there are 5 credits
    When my app makes 5 API calls
    Then there should be 0 credits
    And I should see "You have no more credit. Add more to keep using CoPosition!"
    And I should not be able to make more API calls

  Scenario: a developer adds more credits to their account
    Given there are <start> credits
    When I click the button with <number>
    Then I should see "<number> credits were added"
    And there should be <end> credits

  Examples:
    | start | number | end   |
    | 0     | 10000  | 10000 |
    | 0     | 20000  | 20000 |
    | 1234  | 10000  | 11234 |
    | 20    | 50000  | 50020 |