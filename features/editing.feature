Feature: Editing artefacts
  In order to maintain GovUK metadata
  I want to edit artefacts

  Background:
    Given I am an admin

  Scenario: Editing an artefact and changing the slug
    Given two artefacts exist
    When I change the slug of the first artefact to "a new slug"
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

  Scenario: Trying to create an artefact for a need that is already met
    Given an artefact exists
    When I try to create a new artefact with the same need
    Then I should be redirected to Publisher

  Scenario: Assign a related item
    Given two artefacts exist
    When I create a relationship between them
    Then I should be redirected to Publisher
      And the API should say that the artefacts are related
      And the rest of the system should be notified that the artefact has been updated

  Scenario: Unassign a related item
    Given two artefacts exist
      And the artefacts are related
    When I destroy their relationship
    Then I should be redirected to Publisher
      And the API should say that the artefacts are not related
      And the rest of the system should be notified that the artefact has been updated

  Scenario: Assign additional related items
    Given several artefacts exist
      And some of the artefacts are related
    When I create more relationships between them
    Then I should be redirected to Publisher
      And the API should say that more of the artefacts are related
      And the rest of the system should be notified that the artefact has been updated

#  Scenario: Assign a contact
#    Given an artefact exists
#      And a contact exists
#    When I add the contact to the artefact
#    Then I should be redirected to Publisher
#      And the API should say that the artefact has the contact
#      And the rest of the system should be notified that the artefact has been updated

#  Scenario: Unassign a contact
#    Given an artefact exists
#      And a contact exists
#      And the artefact has the contact
#    When I remove the contact from the artefact
#    Then I should be redirected to Publisher
#      And the API should say that the artefact does not have the contact
#      And the rest of the system should be notified that the artefact has been updated

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
