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
          assert page.has_content?("11 artefacts")
        end
      end

      should "display all artefacts in the list" do
        visit "/artefacts"

        within "table#artefact-list tbody" do
          assert page.has_selector?("tr", count: 11)

          @artefacts.sort_by(&:name).each_with_index do |artefact, i|
            within "tr:nth-of-type(#{i+1})" do
              assert page.has_content?(artefact.name)
              assert page.has_content?(artefact.slug)
            end
          end
        end
      end

      should "display default values for filters" do
        visit "/artefacts"

        within "#filters" do
          assert page.has_selector?("h3", text: "Filters")

          within "form" do
            assert page.has_select?("Format", selected: "All")
            assert page.has_select?("State", selected: "Live")
            assert page.has_field?("Contains", with: nil)
          end

          assert page.has_button?("Update results")
          assert page.has_no_button?("Clear filters")
        end
      end
    end

    should "not show a button to clear filters if none are applied" do
      visit '/artefacts?kind=&state=&search='

      within "#filters" do
        click_on "Update results"
      end

      assert page.has_no_content?("Clear filters")
    end

    should "filter by kind" do
      FactoryGirl.create(:artefact, name: 'An report', kind: "report", state: "live")
      FactoryGirl.create(:artefact, name: 'An course', kind: "course", state: "live")
      FactoryGirl.create(:artefact, name: 'An job', kind: "job", state: "live")

      visit '/artefacts'

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "An report")
        assert page.has_selector?("tr", text: "An course")
        assert page.has_selector?("tr", text: "An job")
      end

      within "#filters" do
        select "Course", from: "Format"
        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "An course")

        assert page.has_no_selector?("tr", text: "An report")
        assert page.has_no_selector?("tr", text: "An job")
      end

      within "#filters" do
        assert page.has_select?("Format", selected: "Course")
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
      FactoryGirl.create(:artefact, name: 'VAT rates', slug: "vat-rates", description: "VAT rates", state: "live")
      FactoryGirl.create(:artefact, name: 'Minimum wage rates', slug: "minimum-wage-rates", description: "VAT rates", kind: "course", state: "live")
      FactoryGirl.create(:artefact, name: 'Bank holidays', slug: "bank-holidays", description: "The next bank holiday", kind: "course", state: "live")

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
      FactoryGirl.create(:artefact, name: 'VAT rates', slug: "vat-rates", state: "live", kind: "case_study")
      FactoryGirl.create(:artefact, name: 'Minimum wage rates', slug: "minimum-wage-rates", state: "draft", kind: "case_study")
      FactoryGirl.create(:artefact, name: 'Bank holidays', slug: "bank-holidays", state: "draft", kind: "course")

      visit '/artefacts'

      within "#filters" do
        select "Case study", from: "Format"
        select "Live", from: "State"

        click_on "Update results"
      end

      within "#artefact-list" do
        assert page.has_selector?("tr", text: "VAT rates")

        assert page.has_no_selector?("tr", text: "Minimum wage rates")
        assert page.has_no_selector?("tr", text: "Bank holidays")
      end

      within "#filters" do
        assert page.has_select?("Format", selected: "Case study")
        assert page.has_select?("State", selected: "Live")
      end
    end
  end
end
