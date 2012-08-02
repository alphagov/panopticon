require_relative '../integration_test_helper'

class ArtefactsIndexTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "link to the published url for the app" do
    FactoryGirl.create(:artefact, :name => 'Alpha', :slug => 'alpha')
    FactoryGirl.create(:artefact, :name => 'Bravo', :slug => 'bravo')
    FactoryGirl.create(:artefact, :name => 'Charlie', :slug => 'charlie')

    visit "/artefacts"

    assert page.has_link?("alpha", :href => "http://www.test.gov.uk/alpha")
    assert page.has_link?("bravo", :href => "http://www.test.gov.uk/bravo")
    assert page.has_link?("charlie", :href => "http://www.test.gov.uk/charlie")
  end
end
