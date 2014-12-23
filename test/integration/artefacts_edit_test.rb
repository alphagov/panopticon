require_relative '../integration_test_helper'
require 'gds_api/test_helpers/need_api'

class ArtefactsEditTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::NeedApi

  setup do
    create_test_user
    stub_all_router_api_requests
    stub_all_rummager_requests
    FactoryGirl.create :odi_role
    FactoryGirl.create :dapaas_role
  end

  def stub_basic_need_api_response(need_id = "100123")
    need_api_has_need(
      "id" => need_id,
      "role" => "user",
      "goal" => "do something",
      "benefit" => "reason"
    )
  end

  context "editing a publisher artefact" do
    setup do
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "business", parent_id: nil, title: "Business")
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "business/employing-people", parent_id: "business", title: "Employing people")
      FactoryGirl.create(:tag, tag_type: "legacy_source", tag_id: "businesslink", parent_id: nil, title: "Business Link")

      @artefact = FactoryGirl.create(:artefact,
                                     name: "VAT Rates", slug: "vat-rates", kind: "answer", state: "live",
                                     owning_app: "publisher", language: "en", business_proposition: true,
                                     section_ids: ["business/employing-people"], legacy_source_ids: ["businesslink"])
    end

    should "display the artefact form" do
      visit "/artefacts/#{@artefact.id}/edit"

      within "header.artefact-header" do
        assert page.has_selector? "h1", text: "VAT Rates"
        assert page.has_link? "/vat-rates", href: "http://www.#{ENV["GOVUK_APP_DOMAIN"]}/vat-rates"
        assert page.has_selector? ".state", text: "live"
      end

      within ".artefact-actions" do
        assert page.has_selector? "li.active", text: "Edit"
        assert page.has_selector? "li:not(.active)", text: "History"
        assert page.has_selector? "li:not(.active)", text: "Archive"
      end

      within ".owning-app" do
        assert page.has_content? "This content is managed in Publisher"
        assert page.has_link? "Edit in Publisher"
      end

      within ".form-actions" do
        assert page.has_button? "Save and continue editing"
        assert page.has_button? "Save and go to item"
      end
    end

    should "not show name or kind fields for an existing artefact" do
      visit "/artefacts/#{@artefact.id}/edit"

      assert page.has_no_field? "Name"
      assert page.has_no_field? "Kind"
    end

    should "not show slug field for a live artefact" do
      visit "/artefacts/#{@artefact.id}/edit"

      assert page.has_no_field? "Slug"
    end

    should "permit changes to the slug for a draft artefact" do
      draft_artefact = FactoryGirl.create(:artefact, state: "draft", slug: "a-pretty-slug")
      visit "/artefacts/#{draft_artefact.id}/edit"

      assert page.has_field? "Slug", with: "a-pretty-slug"
      fill_in "Slug", with: "another-slug"
      click_on "Save and continue editing"

      assert page.has_content? "Panopticon item updated"
      assert page.has_field? "Slug", with: "another-slug"
    end

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
      within ".related-external-links div:first-child", match: :first do
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
