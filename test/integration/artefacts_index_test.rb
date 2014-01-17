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
    setup do
      # this stops the tests blowing up when we create an Artefact with
      # a state of 'live' or 'archived'
      stub_all_router_api_requests
      stub_all_rummager_requests
    end

    context "with no filters" do
      setup do
        @artefacts = FactoryGirl.create_list(:artefact, 10)
      end

      should "show the total number of artefacts" do
        visit "/artefacts"

        within ".artefact-count" do
          assert page.has_content?("10 artefacts")
        end
      end

      should "display all artefacts in the list" do
        visit "/artefacts"

        within "table#artefact-list tbody" do
          assert page.has_selector?("tr", count: 10)

          @artefacts.sort_by(&:name).each_with_index do |artefact, i|
            within "tr:nth-of-type(#{i+1})" do
              assert page.has_content?(artefact.name)
              assert page.has_content?(artefact.slug)
              assert page.has_content?(artefact.kind.humanize)
              assert page.has_content?(artefact.owning_app)
            end
          end
        end
      end

      should "display default values for filters" do
        visit "/artefacts"

        within "#filters" do
          assert page.has_selector?("h3", text: "Filters")

          within "form" do
            assert page.has_select?("Section", selected: "All")
            assert page.has_select?("Industry sector", selected: "All")
            assert page.has_select?("Format", selected: "All")
            assert page.has_select?("State", selected: "All")
            assert page.has_field?("Contains", with: nil)
          end

          assert page.has_button?("Update results")
          assert page.has_no_button?("Clear filters")
        end
      end
    end

    should "not show a button to clear filters if none are applied" do
      visit '/artefacts'

      within "#filters" do
        click_on "Update results"
      end

      assert page.has_no_content?("Clear filters")
    end

    should "filter by section tag" do
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

      within "#filters" do
        select "Driving", from: "Section"
        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "Guide to driving")
        assert page.has_selector?("tr", text: "Book driving test")

        assert page.has_no_selector?("tr", text: "VAT rates")
      end

      within "#filters" do
        assert page.has_select?("Section", selected: "Driving")
      end
    end

    should "filter by industry_sector tag" do
      FactoryGirl.create(:tag, tag_id: 'oil-and-gas', tag_type: 'industry_sector', title: 'Oil and gas')
      FactoryGirl.create(:tag, tag_id: 'oil-and-gas/wells', tag_type: 'industry_sector', title: 'Wells', parent_id: 'oil-and-gas')

      FactoryGirl.create(:artefact, name: 'Something else', slug: 'something-else', industry_sector_ids: [])
      FactoryGirl.create(:artefact, name: 'Oil and gas licensing', slug: 'oil-and-gas-licensing', industry_sector_ids: ['oil-and-gas'])
      FactoryGirl.create(:artefact, name: 'Digging a well', slug: 'digging-wells', industry_sector_ids: ['oil-and-gas/wells'])

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "Something else")
        assert page.has_selector?("tr", text: "Oil and gas licensing")
        assert page.has_selector?("tr", text: "Digging a well")
      end

      within "#filters" do
        select "Oil and gas", from: "Industry sector"
        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "Oil and gas licensing")
        assert page.has_selector?("tr", text: "Digging a well")

        assert page.has_no_selector?("tr", text: "Something else")
      end

      within "#filters" do
        assert page.has_select?("Industry sector", selected: "Oil and gas")
      end
    end

    should "filter by kind" do
      FactoryGirl.create(:artefact, name: 'An answer', kind: "answer")
      FactoryGirl.create(:artefact, name: 'Another answer', kind: "answer")
      FactoryGirl.create(:artefact, name: 'A guide', kind: "guide")
      FactoryGirl.create(:artefact, name: 'A transaction', kind: "transaction")

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "An answer")
        assert page.has_selector?("tr", text: "Another answer")
        assert page.has_selector?("tr", text: "A guide")
        assert page.has_selector?("tr", text: "A transaction")
      end

      within "#filters" do
        select "Answer", from: "Format"
        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "An answer")
        assert page.has_selector?("tr", text: "Another answer")

        assert page.has_no_selector?("tr", text: "A guide")
        assert page.has_no_selector?("tr", text: "A transaction")
      end

      within "#filters" do
        assert page.has_select?("Format", selected: "Answer")
      end
    end

    should "filter by state" do
      FactoryGirl.create(:artefact, name: 'VAT rates', state: "live")
      FactoryGirl.create(:artefact, name: 'Bank holidays', state: "live")
      FactoryGirl.create(:artefact, name: 'Minimum wage', state: "draft")

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")
        assert page.has_selector?("tr", text: "Bank holidays")
        assert page.has_selector?("tr", text: "Minimum wage")
      end

      within "#filters" do
        select "Live", from: "State"
        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")
        assert page.has_selector?("tr", text: "Bank holidays")

        assert page.has_no_selector?("tr", text: "Minimum wage")
      end

      within "#filters" do
        assert page.has_select?("State", selected: "Live")
      end
    end

    should "filter by matching search query" do
      FactoryGirl.create(:artefact, name: 'VAT rates', slug: "vat-rates", description: "VAT rates")
      FactoryGirl.create(:artefact, name: 'Minimum wage rates', slug: "minimum-wage-rates", description: "VAT rates")
      FactoryGirl.create(:artefact, name: 'Bank holidays', slug: "bank-holidays", description: "The next bank holiday")

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")
        assert page.has_selector?("tr", text: "Minimum wage rates")
        assert page.has_selector?("tr", text: "Bank holidays")
      end

      within "#filters" do
        fill_in "Contains", with: "rates"
        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")
        assert page.has_selector?("tr", text: "Minimum wage rates")

        assert page.has_no_selector?("tr", text: "Bank holidays")
      end

      within "#filters" do
        assert page.has_field?("Contains", with: "rates")
      end
    end

    should "filter by multiple criteria" do
      FactoryGirl.create(:artefact, name: 'VAT rates', slug: "vat-rates", state: "live", kind: "answer")
      FactoryGirl.create(:artefact, name: 'Minimum wage rates', slug: "minimum-wage-rates", state: "live", kind: "guide")
      FactoryGirl.create(:artefact, name: 'Bank holidays', slug: "bank-holidays", state: "draft", kind: "custom-application")

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")
        assert page.has_selector?("tr", text: "Minimum wage rates")
        assert page.has_selector?("tr", text: "Bank holidays")
      end

      within "#filters" do
        select "Answer", from: "Format"
        select "Live", from: "State"

        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")

        assert page.has_no_selector?("tr", text: "Minimum wage rates")
        assert page.has_no_selector?("tr", text: "Bank holidays")
      end

      within "#filters" do
        assert page.has_select?("Format", selected: "Answer")
        assert page.has_select?("State", selected: "Live")
      end
    end

    should "filter by multiple tag criteria" do
      FactoryGirl.create(:tag, tag_id: 'driving', tag_type: 'section', title: 'Driving')
      FactoryGirl.create(:tag, tag_id: 'driving/learning-to-drive', tag_type: 'section', title: 'Learning to drive', parent_id: 'driving')

      FactoryGirl.create(:tag, tag_id: 'oil-and-gas', tag_type: 'industry_sector', title: 'Oil and gas')
      FactoryGirl.create(:tag, tag_id: 'oil-and-gas/wells', tag_type: 'industry_sector', title: 'Wells', parent_id: 'oil-and-gas')

      FactoryGirl.create(:artefact, name: 'Motor incidents involving wells', industry_sector_ids: ["oil-and-gas/wells"], section_ids: ["driving/learning-to-drive"])
      FactoryGirl.create(:artefact, name: 'Driving forward the oil and gas industry', industry_sector_ids: ["oil-and-gas"], section_ids: ["driving"])
      FactoryGirl.create(:artefact, name: 'An illustrated history of wells', industry_sector_ids: ["oil-and-gas/wells"], section_ids: [])
      FactoryGirl.create(:artefact, name: 'Getting your provisional licence', industry_sector_ids: [], section_ids: ["driving/learning-to-drive"])

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "Motor incidents involving wells")
        assert page.has_selector?("tr", text: "Driving forward the oil and gas industry")
        assert page.has_selector?("tr", text: "An illustrated history of wells")
        assert page.has_selector?("tr", text: "Getting your provisional licence")
      end

      within "#filters" do
        select "Driving", from: "Section"
        select "Oil and gas", from: "Industry sector"

        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "Motor incidents involving wells")
        assert page.has_selector?("tr", text: "Driving forward the oil and gas industry")

        assert page.has_no_selector?("tr", text: "An illustrated history of wells")
        assert page.has_no_selector?("tr", text: "Getting your provisional licence")
      end

      within "#filters" do
        assert page.has_select?("Section", selected: "Driving")
        assert page.has_select?("Industry sector", selected: "Oil and gas")
      end
    end
  end
end
