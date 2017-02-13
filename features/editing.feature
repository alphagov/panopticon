Feature: Editing artefacts
  In order to maintain GOV.UK metadata
  I want to edit artefacts

  Scenario: Editing an Artefact
    Given an artefact exists
    When I visit the edit page
    Then I should see a callout
      And I should see a link for tagging the item on content-tagger
