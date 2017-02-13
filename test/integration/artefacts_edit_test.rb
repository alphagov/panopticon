require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user
  end

  test "it should display the 'Tagging and user needs have moved' message" do
    artefact = FactoryGirl.create(:artefact, owning_app: OwningApp::PUBLISHER, paths: ["/foo"])

    visit "/artefacts/#{artefact.id}/edit"

    assert page.has_selector? ".callout-title", text: "Improved tagging"
    assert page.has_link? "have moved to Content Tagger", href: Plek.find('content-tagger') + "/content/#{artefact.content_id}"
  end
end
