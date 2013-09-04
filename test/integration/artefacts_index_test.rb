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

    assert page.has_link?("alpha", :href => "http://www.#{ENV["GOVUK_APP_DOMAIN"]}/alpha")
    assert page.has_link?("bravo", :href => "http://www.#{ENV["GOVUK_APP_DOMAIN"]}/bravo")
    assert page.has_link?("charlie", :href => "http://www.#{ENV["GOVUK_APP_DOMAIN"]}/charlie")
  end

  should "display the language for the artefact" do
    FactoryGirl.create(:artefact, :name => 'Alpha', :slug => 'alpha', :language => "en")
    FactoryGirl.create(:artefact, :name => 'Bravo', :slug => 'bravo', :language => "cy")

    visit "/artefacts"

    alpha = find('tr', :text => "Alpha")
    bravo = find('tr', :text => "Bravo")

    assert alpha.has_content?("en")
    assert bravo.has_content?("cy")
  end
end
