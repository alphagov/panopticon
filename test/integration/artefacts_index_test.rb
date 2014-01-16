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

    assert page.has_link?("alpha", :href => "http://www.dev.gov.uk/alpha")
    assert page.has_link?("bravo", :href => "http://www.dev.gov.uk/bravo")
    assert page.has_link?("charlie", :href => "http://www.dev.gov.uk/charlie")
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

  context "filtering artefacts" do
    should "filter by section" do
      FactoryGirl.create(:tag, tag_id: 'driving', tag_type: 'section', title: 'Driving')
      FactoryGirl.create(:tag, tag_id: 'driving/learning-to-drive', tag_type: 'section', title: 'Learning to drive', parent_id: 'driving')

      FactoryGirl.create(:artefact, name: 'VAT rates', slug: 'vat-rates', section_ids: [])
      FactoryGirl.create(:artefact, name: 'Guide to driving', slug: 'guide-to-driving', section_ids: ['driving'])
      FactoryGirl.create(:artefact, name: 'Book driving test', slug: 'book-driving-test', section_ids: ['driving/learning-to-drive'])

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")
        assert page.has_selector?("tr", text: "Guide to driving")
        assert page.has_selector?("tr", text: "Book driving test")
      end

      within ".sidebar-nav ul" do
        assert page.has_selector?("li.active", text: "All")
        assert page.has_selector?("li:not(.active)", text: "Driving")

        click_on "Driving"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "Guide to driving")
        assert page.has_selector?("tr", text: "Book driving test")

        assert page.has_no_selector?("tr", text: "VAT rates")
      end

      within ".sidebar-nav ul" do
        assert page.has_selector?("li:not(.active)", text: "All")
        assert page.has_selector?("li.active", text: "Driving")
      end
    end
  end
end
