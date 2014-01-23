Feature: Managing sections
  In order to build GovUK^W theodi.org
  I want to manage section homepages with a nice GUI
  
  Background:
    Given I am an admin
    And I have the "Manage sections" permission
    
  Scenario: Creating sections
    Given I have the "Create sections" permission
    When I visit the homepage
    Then I should see the link to manage sections
    
    When I follow the link to manage sections    
    And I click the Add new section link
    Then I should see the Add new section form
    
    When I fill in the form for a new section
    Then I should get redirected to the section list
    And I should see a message saying my section has been created
    And I should see my section in the list
  
  Scenario: Trying to create section without the correct permissions
    When I follow the link to manage sections
    Then I should not see the Add new section link
    
  Scenario: Uploading hero image
    Given I have the "Create sections" permission
    When I visit the page to add a new section
    And I add an image to upload
    And I fill in the form for a new section
    Then I should get redirected to the section list
    And I should see a message saying my section has been created
    And my section should have the image associated with it
  
  Scenario: Replacing hero image
    Given I have the "Create sections" permission
    And a section with an image already exists
    When I access the page for that section
    And I specify a new image
    Then my section should have the image associated with it
    
  Scenario: Removing hero image
    Given I have the "Create sections" permission
    And a section with an image already exists
    When I access the page for that section
    And I click the remove image checkbox on the section page
    Then my section should not have an image associated with it