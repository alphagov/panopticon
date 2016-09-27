require 'integration_test_helper'
require 'gds_api/test_helpers/router'

class ArtefactWithdrawTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::Router

  setup do
    create_test_user
  end

  context "for a whitehall artefact" do
    setup do
      without_artefact_callbacks do
        @artefact = FactoryGirl.create(:whitehall_live_artefact, paths: ["/foo"])
      end
    end

    should "not show the withdraw tab" do
      visit "/artefacts/#{@artefact.id}/edit"
      assert_no_selector("ul.artefact-actions li a", text: "Withdraw")
    end

    should "redirect away from the withdraw page" do
      visit "/artefacts/#{@artefact.id}/withdraw"
      assert_equal "/artefacts", current_path
    end
  end

  context "for an archived artefact" do
    setup do
      without_artefact_callbacks do
        @artefact = FactoryGirl.create(:archived_artefact, paths: ["/foo"])
      end
    end

    should "not show the withdraw tab" do
      visit "/artefacts/#{@artefact.id}/edit"
      assert_no_selector("ul.artefact-actions li a", text: "Withdraw")
    end

    should "redirect away from the withdraw page" do
      visit "/artefacts/#{@artefact.id}/withdraw"
      assert_equal "/artefacts", current_path
    end
  end

  context "for a live artefact" do
    setup do
      without_artefact_callbacks do
        @artefact = FactoryGirl.create(:live_artefact, paths: ["/foo"])
      end
    end

    should "show the withdraw tab" do
      visit "/artefacts/#{@artefact.id}/edit"
      assert_selector("ul.artefact-actions li a", text: "Withdraw")
    end

    should "set a Gone route when archiving without a redirect" do
      stub_router_backend_registration("publisher",
        Plek.current.find("publisher", :force_http => true) + "/")

      gone_request, commit_request = stub_gone_route_registration("/foo", "exact")

      visit "/artefacts/#{@artefact.id}/withdraw"
      click_button "Withdraw"

      assert_requested gone_request
      assert_requested commit_request
    end

    should "set a Redirect route when archiving with a relative redirect" do
      stub_router_backend_registration("publisher",
        Plek.current.find("publisher", :force_http => true) + "/")

      redirect_request, commit_request = stub_redirect_registration("/foo",
                                                                    "exact",
                                                                    "/bar",
                                                                    "permanent")

      visit "/artefacts/#{@artefact.id}/withdraw"
      fill_in "artefact_redirect_url", with: "/bar"
      click_button "Withdraw"

      assert_requested redirect_request
      assert_requested commit_request
    end

    should "set a Redirect route when archiving with a GOV.UK redirect" do
      stub_router_backend_registration("publisher",
        Plek.current.find("publisher", :force_http => true) + "/")

      redirect_request, commit_request = stub_redirect_registration("/foo",
                                                                    "exact",
                                                                    "/bar",
                                                                    "permanent")

      visit "/artefacts/#{@artefact.id}/withdraw"
      fill_in "artefact_redirect_url", with: "https://www.gov.uk/bar"
      click_button "Withdraw"

      assert_requested redirect_request
      assert_requested commit_request
    end

    should "show an error when archiving with an external redirect" do
      visit "/artefacts/#{@artefact.id}/withdraw"
      fill_in "artefact_redirect_url", with: "https://www.example.com/bar"
      click_button "Withdraw"

      assert_selector ".alert-danger"
    end
  end
end
