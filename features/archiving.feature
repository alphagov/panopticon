Feature: Archiving artefacts
  In order to maintain current content on GOV.UK
  I want to archive artefacts

  Background:
    Given I am an admin
      And I have stubbed the router
      And I have stubbed search

  Scenario: Archiving a live artefact
    Given a live artefact exists
    And I click the archive tab on the artefact page
    And I archive the existing artefact
    Then I should get redirected to the homepage

  Scenario: Archiving an already archived artefact
    Given an archived artefact exists
    Then I should not see the archive tab along with the edit and history tabs
    When I browse to the "/archive" URL for the artefact
    Then I should get redirected to the homepage
