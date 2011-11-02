Feature: Editing artefacts
  In order to maintain GovUK metadata
  I want to edit artefacts

  Scenario: Assign a related item
    Given there are artefacts called "Probation" and "Leaving prison"
      And no notifications have been sent

    Then the API should say that "Leaving prison" is not related to "Probation"

    When I am editing "Probation"
      And I add "Leaving prison" as a related item
      And I save my changes

    Then I should be redirected to "Probation" on Publisher
      And the rest of the system should be notified that "Probation" has been updated
      And the API should say that "Leaving prison" is related to "Probation"

  Scenario: Unassign a related item
    Given there are artefacts called "Probation" and "Leaving prison"
      And "Leaving prison" is related to "Probation"
      And no notifications have been sent

    Then the API should say that "Leaving prison" is related to "Probation"

    When I am editing "Probation"
      And I remove "Leaving prison" as a related item
      And I save my changes

    Then I should be redirected to "Probation" on Publisher
      And the rest of the system should be notified that "Probation" has been updated
      And the API should say that "Leaving prison" is not related to "Probation"

  Scenario: Assign additional related items
    Given there are artefacts called "Driving disqualifications", "Book the practical driving test", "Driving before your licence is returned", "National Driver Offender Retraining Scheme", "Apply for a new driving licence" and "Get a divorce"
      And "Book the practical driving test" and "Driving before your licence is returned" are related to "Driving disqualifications"
      And no notifications have been sent

    Then the API should say that "Book the practical driving test" and "Driving before your licence is returned" are related to "Driving disqualifications"
      And the API should say that "National Driver Offender Retraining Scheme", "Apply for a new driving licence" and "Get a divorce" are not related to "Driving disqualifications"

    When I am editing "Driving disqualifications"
      And I add "National Driver Offender Retraining Scheme" as a related item
      And I add "Apply for a new driving licence" as a related item
      And I save my changes

    Then I should be redirected to "Driving disqualifications" on Publisher
      And the rest of the system should be notified that "Driving disqualifications" has been updated
      And the API should say that "Book the practical driving test", "Driving before your licence is returned", "National Driver Offender Retraining Scheme" and "Apply for a new driving licence" are related to "Driving disqualifications"
      And the API should say that "Get a divorce" is not related to "Driving disqualifications"

  Scenario: Assign a contact
    Given there is an artefact called "Child Benefit rates"
      And there is a contact called "Child Support Agency"
      And no notifications have been sent

    Then the API should say that "Child Support Agency" is not a contact for "Child Benefit rates"

    When I am editing "Child Benefit rates"
