require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user
    stub_all_router_api_requests
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
end
