Feature: Editing artefacts
  In order to maintain GovUK metadata
  I want to edit artefacts

  Scenario: Assign a related item
    Given an artefact exists with a name of "Probation"
      And an artefact exists with a name of "Leaving prison"

    When I am editing "Probation"
      And I add "Leaving prison" as a related item
