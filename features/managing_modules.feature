Feature: Managing sections
  In order to build GovUK^W theodi.org
  I want to manage section homepage modules with a nice GUI
  
  Background:
    Given I am an admin
    And I have the "Manage sections" permission
    
  Scenario: Creating sections
    When I visit the homepage
    Then I should see the link to manage modules
    
    When I click the link to manage modules
    And I click the link to add a new module
    Then I should see the module form
    
    When I fill out the form for a new module
    Then I should get redirected to the module list
    And I should see a message saying my module has been created
    And I should see my module in the list
    
  Scenario: Uploading image
    When I visit the page to add a new module
    And I add a module image to upload
    And I fill in the form for a new module
    Then I should get redirected to the module list
    And I should see a message saying my module has been created
    And my module should have the image associated with it

  Scenario: Replacing image
    Given a module with an image already exists
    When I access the page for that module
    And I specify a new module image
    Then my module should have the image associated with it
    
  Scenario: Removing image
    And a module with an image already exists
    When I access the page for that module
    And I click the remove image checkbox on the module page
    Then my module should not have an image associated with it
