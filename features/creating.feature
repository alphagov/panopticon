Feature: Creating artefacts
  In order to build GovUK
  I want to create artefacts in panopticon

  Background:
    Given I am an admin

  Scenario: Creating artefacts directly in panopticon
    When I visit the homepage
    Then I should see a link to create an item

    When I follow the link link to create an item
    Then I should see the artefact form

    When I fill in the form for a business need
      And I save, indicating that I want to go to the item

    Then I should be redirected to Publisher

  Scenario: Trying to create an artefact for a need that is already met
    Given an artefact exists
    When I try to create a new artefact with the same need
    Then I should be redirected to Publisher

  Scenario Outline: Trying to create an artefact that has tags without specifying a tag
    Given I try to create a <kind> without specifying a tag
    Then I should see an error relating to <kind>

    Examples:
      | kind         |
      | Person       |
      | Article      |
      | Organization |
      | Timed item   |

  Scenario: Creating keywords with permission
    Given I have the "keywords" permission
    And I follow the link link to create an item
    Then the "artefact_keywords" field should be editable
    When I specify the keywords "foo, bar, baz"
    Then I should be redirected to Publisher
    And the artefact should have the keyword "foo"
    And the artefact should have the keyword "bar"
    And the artefact should have the keyword "baz"

  Scenario: Creating keywords with a phrase
    Given I have the "keywords" permission
    And I follow the link link to create an item
    Then the "artefact_keywords" field should be editable
    When I specify the keywords "foo, bar, baz, binky boo"
    Then I should be redirected to Publisher
    And the artefact should have the keyword "foo"
    And the artefact should have the keyword "bar"
    And the artefact should have the keyword "baz"
    And the artefact should have the keyword "binky boo"

  Scenario: Creating keywords without permission
    Given I do not have the "keywords" permission
    And I follow the link link to create an item
    Then the "artefact_keywords" field should be disabled
