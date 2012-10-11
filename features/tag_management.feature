Feature: Managing tags
  In order to curate GovUK content
  I want to manage tags in panopticon

  Background:
    Given I am an admin
    And a category tag called "Crime and Justice" exists

  Scenario: Updating a tag title
    When I visit the categories page
      And I follow the link to edit the category
      And I change the category title to "Crime, justice and superheroes"

    Then I should see "Successfully updated"
      And I should see "Crime, justice and superheroes"
