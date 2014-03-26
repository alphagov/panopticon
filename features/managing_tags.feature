Feature: Managing tags

  Scenario: Creating a new tag
    Given I am a user who can edit tags
    When I create a new tag
    Then the tag should appear in the list
