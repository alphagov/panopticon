Feature: Editing artefacts
  In order to maintain GOV.UK metadata
  I want to edit artefacts

  Background:
    Given I am an admin
      And I have stubbed the router
      And I have stubbed search

  Scenario: Editing an artefact and changing the slug
    Given two artefacts exist
    When I change the slug of the first artefact to "a-new-slug"
    And I save
    Then I should see the edit form again
      And I should see an indication that the save worked

  @javascript
  Scenario: Editing an artefact and returning to edit some more
    Given two artefacts exist
    When I change the need ID of the first artefact
      And I save, indicating that I want to continue editing afterwards
    Then I should be redirected back to the edit page
      And I should see an indication that the save worked

  Scenario: Trying to create an artefact for a need that is already met
    Given an artefact created by Publisher exists
    When I try to create a new artefact with the same need
    Then I should be redirected to Publisher

  @javascript
  Scenario: Editing an item that's draft
    Given two artefacts exist
      And the first artefact is in draft
    When I change the need ID of the first artefact
      And I save

  Scenario: Editing the links of an Artefact
    Given an artefact exists
    When I visit the edit page
    Then I should see a callout
      And I should see a link for tagging the item on content-tagger
