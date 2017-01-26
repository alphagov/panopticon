Feature: Editing artefacts
  In order to maintain GOV.UK metadata
  I want to edit artefacts

  Background:
    Given I am an admin

  @javascript
  Scenario: Editing an artefact and returning to edit some more
    Given two artefacts exist
    When I change the need ID of the first artefact
      And I save, indicating that I want to continue editing afterwards
    Then I should be redirected back to the edit page
      And I should see an indication that the save worked

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
