Feature: Editing artefacts
  In order to maintain GovUK metadata
  I want to edit artefacts

  Background:
    Given I am an admin
      And I have stubbed search and router

  Scenario: Editing an artefact and changing the slug
    Given two artefacts exist
    When I change the slug of the first artefact to "a-new-slug"
    And I save
    Then I should see the edit form again
      And I should see an indication that the save worked

  Scenario: Editing an artefact and returning to edit some more
    Given two artefacts exist
    When I change the title of the first artefact
      And I mark relatedness as done
      And I save, indicating that I want to continue editing afterwards
    Then I should be redirected back to the edit page
      And I should see an indication that the save worked

  Scenario: Add a section
    Given an artefact exists
      And a section exists
    When I add the section to the artefact
    Then I should be redirected to Publisher
      And the API should say that the artefact has the section

  Scenario: Remove a section
    Given an artefact exists
      And a section exists
      And the artefact has the section
    When I remove the section from the artefact
    Then I should be redirected to Publisher
      And the API should say that the artefact does not have the section

  Scenario: Editing an item that's draft
    Given two artefacts exist
      And the first artefact is in draft
    When I change the title of the first artefact
      And I save
    Then rummager should not be notified
      And the router should not be notified

  @wip
  Scenario: Editing a live item
    Given two artefacts exist
      And the first artefact is live
    When I change the title of the first artefact
      And I save
    Then rummager should be told to do a partial update
      And the router should be notified

  @wip
  Scenario: Editing a live item's slug
    When I edit a live item's slug
    Then rummager should be told to do a partial update
      And the router should be told to create a redirect
