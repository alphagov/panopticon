Feature: Related items
  In order to help visitors find their way on GovUK
  I want to assign related items to artefacts

  Background:
    Given I am an admin

  Scenario: Assign a related item
    Given two non-publisher artefacts exist
    When I create a relationship between them
      And I save
    Then the API should say that the artefacts are related

  Scenario: Unassign a related item
    Given two artefacts exist
      And the artefacts are related
    When I destroy their relationship
    Then I should be redirected to Publisher
      And the API should say that the artefacts are not related
