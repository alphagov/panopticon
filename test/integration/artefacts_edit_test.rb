require_relative '../integration_test_helper'
require 'gds_api/test_helpers/need_api'

class ArtefactsEditTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::NeedApi

  setup do
    create_test_user
  end

  def stub_basic_need_api_response(need_id = "100123")
    need_api_has_need(
      "id" => need_id,
      "role" => "user",
      "goal" => "do something",
      "benefit" => "reason"
    )
  end

  should "link to the live site from the edit form" do
    artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_link?("View on site", :href => "http://www.#{ENV["GOVUK_APP_DOMAIN"]}/alpha")
  end

  # skip all these tests, odi does not make use of needs
  context "displaying need information" do
    context "when a Maslow need ID present" do
      setup do
        @artefact = FactoryGirl.create(:artefact, :need_id => "100123")
      end

      should "show basic information about a need from the API" do
        skip("we do not care about needs. Form is disabled.")
        need_api_has_need(
          "id" => "100123",
          "role" => "user",
          "goal" => "buy bunting",
          "benefit" => "bunting"
        )

        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          within ".need-body" do
            assert page.has_content?("As a user")
            assert page.has_content?("I need to buy bunting")
            assert page.has_content?("So that bunting")
          end

          assert page.has_link?("View in Maslow", href: "http://maslow.dev.gov.uk/needs/100123")
        end
      end

      should "not display the need id field" do
        skip("we do not care about needs. Form is disabled.")
        stub_basic_need_api_response

        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_field?("Need ID")
        end
      end

      should "show a disabled need_id field and a link to Maslow when the Need API request is unsuccessful" do
        skip("we do not care about needs. Form is disabled.")
        need_api_has_no_need("100123")

        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_selector?(".need-body")

          field = page.find_field("Need ID")
          assert field[:disabled]

          assert page.has_link?("View in Maslow", href: "http://maslow.dev.gov.uk/needs/100123")
        end
      end
    end

    context "when a Need-o-tron ID present" do
      setup do
        @artefact = FactoryGirl.create(:artefact, :need_id => "99999")
      end

      should "not show additional need information" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_selector?(".need-body")
        end
      end

      should "allow editing of the need ID" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        field = page.find_field("Need ID")
        assert field[:disabled].nil?

        fill_in "Need", :with => "2345"
        click_on "Save and continue editing"

        @artefact.reload
        assert_equal "2345", @artefact.need_id
      end

      should "link to the Need-o-tron" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_link?("View in Needotron", :href => "http://needotron.dev.gov.uk/needs/99999")
        end
      end
    end

    context "when a non-numeric need ID present" do
      setup do
        @artefact = FactoryGirl.create(:artefact, :need_id => "B241")
      end

      should "not show additional need information" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_selector?(".need-body")
        end
      end

      should "allow editing of the Need ID" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        field = page.find_field("Need ID")
        assert field[:disabled].nil?

        fill_in "Need", :with => "2345"
        click_on "Save and continue editing"

        @artefact.reload
        assert_equal "2345", @artefact.need_id
      end

      should "not link to Maslow or the Need-o-tron" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_link?("View in Needotron")
          assert page.has_no_link?("View in Maslow")
        end
      end
    end

    context "when the need ID is blank" do
      setup do
        @artefact = FactoryGirl.create(:artefact, :need_id => "")
      end

      should "not show additional need information" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_selector?(".need-body")
        end
      end

      should "allow editing of the Need ID" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        field = page.find_field("Need ID")
        assert field[:disabled].nil?

        fill_in "Need", :with => "2345"
        click_on "Save and continue editing"

        @artefact.reload
        assert_equal "2345", @artefact.need_id
      end

      should "not link to Maslow or the Need-o-tron" do
        skip("we do not care about needs. Form is disabled.")
        visit "/artefacts/#{@artefact.id}/edit"

        within "#user-need" do
          assert page.has_no_link?("View in Needotron")
          assert page.has_no_link?("View in Maslow")
        end
      end
    end
  end

  context "editing legacy_sources" do
    setup do
      @bl   = FactoryGirl.create(:tag, :tag_type => 'legacy_source', :tag_id => 'businesslink', :title => 'Business Link')
      @dg   = FactoryGirl.create(:tag, :tag_type => 'legacy_source', :tag_id => 'directgov', :title => 'Directgov')
      @dvla = FactoryGirl.create(:tag, :tag_type => 'legacy_source', :tag_id => 'dvla', :title => 'DVLA')
      @a = FactoryGirl.create(:artefact, :name => "VAT")
    end

    should "allow adding legacy sources to artefacts" do
      visit "/artefacts"
      click_on "VAT"

      select "Business Link", :from => "artefact[legacy_source_ids][]"
      select "DVLA", :from => "artefact[legacy_source_ids][]"
      click_on "Save and continue editing"

      @a.reload
      assert_equal 2, @a.legacy_sources.count
      assert @a.legacy_sources.include?(@dvla)
      assert @a.legacy_sources.include?(@bl)
    end

    should "allow removing legacy sources from artefacts" do
      @a.legacy_source_ids = ['businesslink', 'directgov']
      @a.save!

      visit "/artefacts"
      click_on "VAT"

      unselect "Directgov", :from => "artefact[legacy_source_ids][]"
      click_on "Save and continue editing"

      @a.reload
      assert_equal [@bl], @a.legacy_sources
    end
  end

  context "editing language" do
    setup do
      @artefact = FactoryGirl.create(:artefact, :name => "Bank holidays", :language => nil)
    end

    should "allow changing language for an artefact" do
      visit "/artefacts"
      click_on "Bank holidays"

      select "Welsh", :from => "artefact[language]"
      click_on "Save and continue editing"

      @artefact.reload
      assert_equal "cy", @artefact.language
    end

    should "select english language by default" do
      visit "/artefacts"
      click_on "Bank holidays"

      click_on "Save and continue editing"

      @artefact.reload
      assert_equal "en", @artefact.language
    end
  end

  should "not include completed transactions in related item lists" do
    a = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')
    b = FactoryGirl.create(:artefact, :name => "Beta", :slug => 'beta')
    c = FactoryGirl.create(:artefact, :name => "Done", :slug => 'done/completed-example', :kind => 'completed_transaction')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_selector?("#artefact_related_artefact_ids_ option[value='#{b.id}']")
    assert ! page.has_selector?("#artefact_related_artefact_ids_ option[value='#{c.id}']")
  end

  context "related external links" do
    setup do
      Capybara.current_driver = Capybara.javascript_driver
      @artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => "alpha")
    end

    should "be able to add related external links" do
      visit "/artefacts"
      click_on "Alpha"
      click_on "Add related external link"
      within ".related-external-links div:first-child" do
        fill_in "Title", :with => "BBC"
        fill_in "URL", :with => "http://bbc.co.uk"
      end

      click_on "Save and continue editing"
      @artefact.reload
      assert_equal 1, @artefact.external_links.length
      assert_equal "BBC", @artefact.external_links.first.title
    end

  end
end
