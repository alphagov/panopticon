Feature: Managing curated lists
  In order to curate GovUK content
  I want to manage curated lists in panopticon

  Background:
    Given I am an admin
    And my basic set of tags exist

  Scenario: Uploading a new CSV file
    When I visit the curated list admin page
      And I upload my CSV file

    Then I should see "Hooray! That worked and you can now upload new data."
      And the curated lists should exist
