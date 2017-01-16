require 'integration_test_helper'
require 'gds_api/test_helpers/router'

class ArtefactWithdrawTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::Router

  setup do
    create_test_user
  end

  test "it should display the 'Withdrawing has moved' message" do
    artefact = FactoryGirl.create(:artefact, owning_app: OwningApp::PUBLISHER, paths: ["/foo"])

    visit "/artefacts/#{artefact.id}/withdraw"

    assert page.has_selector? ".callout-title", text: "Withdraw"
    assert page.has_link? "has moved", href: Plek.find('publisher') + "/admin/publications/#{artefact.id}"
  end
end
