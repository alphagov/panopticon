@wip
Feature: Registering resources
  In order to introduce new resources into the system
  I want to register artefacts in panopticon
  So that it can co-ordinate the system
  
  Scenario: Creating a smart answer
    When I put a new smart answer's details into panopticon
    Then a new artefact should be created
      And rummager should be notified
      And the router should be notified

  Scenario: Updating a smart answer
    When I put updated smart answer details into panopticon
    Then the relevant artefact should be updated
      And rummager should be notified
      And the router should be notified

  Scenario: Creating a draft item
    When I put a draft smart answer's details into panopticon
    Then a new artefact should be created
      And rummager should not be notified
      And the router should not be notified

  # Scenario: Putting an item whose slug is owned by another app
  #   When I put a new item into panopticon whose slug is already taken
  #   Then I should receive an HTTP 409 response
  #     And the relevant artefact should not be updated

  # Scenario: Editing an item that's draft
  #   When I edit a draft item's details
  #   Then rummager should not be notified
  #     And the router should not be notified

  # Scenario: Editing a live item
  #   When I edit a live item's details but not it's slug
  #   Then rummager should be notified
  #     And the router should not be notified

  # Scenario: Editing a live item's slug
  #   When I edit a live item's slug
  #   Then rummager should be told to do a partial update
  #     And the router should be told to create a redirect
