require_relative '../integration_test_helper'

class ArtefactCreateTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "allow creation of help_page artefacts" do
    skip('Help pages are GOV.UK specific and exist only in govuk_content_models')
    visit "/artefacts"
    click_on "Add artefact"

    within "#edit_artefact" do
      fill_in "Name", :with => "Super helpful page"
      fill_in "Slug", :with => "help/super-helpful"
      select "Help page", :from => "Kind"

      click_on "Save and continue editing"
    end

    refute_nil Artefact.find_by_slug('help/super-helpful')
  end
end
