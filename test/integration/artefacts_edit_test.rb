require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user
    stub_all_router_api_requests
  end

  context "when editing an artefact from the Publisher application" do
    setup do
      @artefact = FactoryGirl.create(
        :artefact,
        name: "VAT Rates",
        slug: "vat-rates",
        kind: "answer",
        state: "live",
        owning_app: "publisher",
        language: "en",
      )
    end

    should "display the artefact form" do
      visit "/artefacts/#{@artefact.id}/edit"

      within "header.artefact-header" do
        assert page.has_selector? "h1", text: "VAT Rates"
        assert page.has_link? "/vat-rates", href: "http://www.dev.gov.uk/vat-rates"
        assert page.has_selector? ".state", text: "live"
      end

      within ".artefact-actions" do
        assert page.has_selector? "li.active", text: "Edit"
        assert page.has_selector? "li:not(.active)", text: "History"
        assert page.has_selector? "li:not(.active)", text: "Withdraw"
      end

      within ".owning-app" do
        assert page.has_content? "This content is managed in Publisher"
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

  context "need_ids" do
    setup do
      Capybara.current_driver = Capybara.javascript_driver
    end

    should "allow editing of need IDs when a Maslow need ID is present" do
      artefact = FactoryGirl.create(:artefact, :need_ids => ["100123"])

      visit "/artefacts/#{artefact.id}/edit"

      add_need_id "100123"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal ["100123"], artefact.need_ids
    end

    should "allow editing of the need ID when a Need-o-tron ID present" do
      artefact = FactoryGirl.create(:artefact)
      artefact.update_attribute(:need_ids, ["99999"])

      visit "/artefacts/#{artefact.id}/edit"

      add_need_id "100012"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal ["99999", "100012"], artefact.need_ids
    end

    should "allow editing of the Need ID" do
      artefact = FactoryGirl.create(:artefact)
      artefact.update_attribute(:need_ids, ["B241"])

      visit "/artefacts/#{artefact.id}/edit"

      add_need_id "100012"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal ["B241", "100012"], artefact.need_ids
    end

    should "allow editing of the Need IDs when need IDs is blank" do
      artefact = FactoryGirl.create(:artefact, :need_ids => [])
      visit "/artefacts/#{artefact.id}/edit"

      add_need_id "100012"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal ["100012"], artefact.need_ids
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

  context "relating artefacts" do
    context "without javascript" do
      setup do
        @artefact = FactoryGirl.create(:artefact, content_id: SecureRandom.uuid)
        @artefacts_to_relate = *FactoryGirl.create_list(:artefact, 2)
        @request_to_patch_links = stub_request(:patch, "http://publishing-api.dev.gov.uk/v2/links/#{@artefact.content_id}").
          to_return(body: {}.to_json)
      end

      should "be done by entering slugs of artefacts to relate" do
        visit edit_artefact_path(@artefact)

        fill_in "Related artefact slugs", with: @artefacts_to_relate.map(&:slug).join(", ")
        click_on "Save and continue editing"

        assert_equal @artefacts_to_relate.map(&:slug).join(", "), find_field("Related artefact slugs").value
        assert_requested @request_to_patch_links
      end
    end
  end
end
