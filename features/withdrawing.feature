Feature: Withdrawing artefacts
  In order to maintain current content on GOV.UK
  I want to withdraw artefacts

  Background:
    Given I am an admin
      And I have stubbed the router
      And I have stubbed search

  Scenario: Withdrawing a live artefact
    Given a live artefact exists
    And I click the withdraw tab on the artefact page
    And I withdraw the existing artefact
    Then I should get redirected to the homepage

  Scenario: Withdrawing an already withdrawn artefact
    Given a withdrawn artefact exists
    Then I should not see the withdraw tab along with the edit and history tabs
    When I go to the withdraw URL for the artefact
    Then I should get redirected to the homepage
