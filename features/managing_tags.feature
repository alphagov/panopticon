Feature: Managing tags

  Scenario: Creating a new tag
    Given I am a user who can edit tags
    When I create a new tag
    Then the tag should appear in the list
    And the tag should be marked as draft in the list

  Scenario: Editing a tag
    Given I am a user who can edit tags
    And a tag exists
    When I edit the tag
    Then the updated tag should appear in the list

  Scenario: Publishing a tag
    Given I am a user who can edit tags
    And a draft tag exists
    When I publish the tag
    Then the tag should appear as live
