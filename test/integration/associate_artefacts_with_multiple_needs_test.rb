require_relative '../integration_test_helper'

class AssociateArtefactsWithMultipleNeedsTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user
    Capybara.current_driver = Capybara.javascript_driver
  end

  should "associate multiple needs to an artefact" do
    artefact = FactoryGirl.create(:artefact)

    visit "/artefacts/#{artefact.id}/edit"

    add_need_id "100123"
    add_need_id "100124"
    add_need_id "100125"
    click_on "Save and continue editing"

    visit "/artefacts"
    assert_equal ["100123", "100124", "100125"], page.all("#artefact-list span.need-id").map(&:text)
  end
end
