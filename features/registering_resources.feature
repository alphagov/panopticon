Feature: Registering resources
  In order to introduce new resources into the system
  I want to register artefacts in panopticon
  So that it can co-ordinate the system

  @wip
  Scenario: Creating a smart answer
    When I post a smart answer's details into panopticon
    Then I should have an artefact created
    And rummager should be notified
