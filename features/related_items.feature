Feature: Related items
  In order to help visitors find their way on GovUK
  I want to assign related items to artefacts

  Background:
    Given I am an admin

  @javascript
  Scenario: Assign a related item
    Given two artefacts from a non migrated app exist
     When I create a relationship between them
      And I save
     Then the API should say that the artefacts are related

  @javascript
  Scenario: Unassign a related item
    Given two artefacts exist
      And the artefacts are related
     When I destroy their relationship
      And the API should say that the artefacts are not related
