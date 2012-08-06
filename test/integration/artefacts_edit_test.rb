require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "link to the live site from the edit form" do
    artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_link?("View on site", :href => "http://www.test.gov.uk/alpha")
  end
end
