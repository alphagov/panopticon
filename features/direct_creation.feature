Feature: Creating artefacts directly
  In order to support multiple propositions
  I want to create artefacts directly in panopticon
  So I am not prematurely committed to need-o-tron

  Background:
    Given I am an admin

  Scenario:
    When I visit the homepage
    Then I should see a link to create an item

    When I follow the link link to create an item
    Then I should see the artefact form

    When I fill in the form for a business need
      And I save, indicating that I want to go to the item

    Then I should be redirected to Publisher