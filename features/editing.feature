Feature: Editing artefacts
  In order to maintain GovUK metadata
  I want to edit artefacts

  Scenario: Assign a related item
    Given an artefact exists with a name of "Probation"
      And an artefact exists with a name of "Leaving prison"

    Then the API should say that "Leaving prison" is not related to "Probation"

    When I am editing "Probation"
      And I add "Leaving prison" as a related item
      And I save my changes

    Then I should be redirected to "Probation" on Publisher
      And the rest of the system should be notified that "Probation" has been updated
      And the API should say that "Leaving prison" is related to "Probation"
