Feature: Registering resources
  In order to introduce new resources into the system
  I want to register artefacts in panopticon
  So that it can co-ordinate the system

  Scenario: Creating a person
    When I put a new person's details into panopticon
    Then a new artefact should be created
      And rummager should not be notified

  Scenario: Updating a person
    When I put an updated person's details into panopticon
    Then the relevant artefact should be updated
      And the API should reflect the change
      And rummager should not be notified

  Scenario: Creating a draft news item
    When I put a draft news item's details into panopticon
    Then a new artefact should be created
      And rummager should not be notified

  Scenario: Creating a news item
    When I put a new news item's details into panopticon
    Then a new artefact should be created
      And rummager should be notified

  Scenario: Putting an item whose slug is owned by another app
    When I put a new item into panopticon whose slug is already taken
    Then I should receive an HTTP 409 response
      And the relevant artefact should not be updated

  Scenario: Deleting an item
    When I delete an artefact
    Then the artefact state should be archived
     And rummager should be notified of the delete
