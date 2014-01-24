require_relative '../integration_test_helper'

class ArtefactCreateTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
    stub_all_router_api_requests
  end

  should "allow the use of deep slugs when creating a whitehall artefact" do
    visit "/artefacts"
    click_on "Add Whitehall artefact"

    within("form#edit_artefact") do
      fill_in "Name", :with => "British Embassy Legoland"
      fill_in "Description", :with => "Some information on the British Embassy in Legoland"
      fill_in "Slug", :with => "government/world/organisations/british-embassy-legoland"
      select "Worldwide priority", :from => "Kind"
      click_on "Save and continue editing"

      artefact = Artefact.where(:slug => 'government/world/organisations/british-embassy-legoland').last

      assert_equal "/artefacts/#{artefact.to_param}/edit", current_path
    end

    assert page.has_link?("/government/world/organisations/british-embassy-legoland")
    assert page.has_no_css?(".alert.alert-error"), "No form errors were expected"
  end

  should "not allow the use of invalid slugs when creating a whitehall artefact" do
    visit "/artefacts"
    click_on "Add Whitehall artefact"

    within("form#edit_artefact") do
      fill_in "Name", :with => "British Embassy Legoland"
      fill_in "Description", :with => "Some information on the British Embassy in Legoland"
      fill_in "Slug", :with => "government/world/.organi$ation$/briti$h~embassy~legoland"
      select "Worldwide priority", :from => "Kind"
      click_on "Save and continue editing"
    end

    assert_equal "/artefacts", current_path
    
    within(".alert.alert-error") do
      assert page.has_content?("Slug must be usable in a URL") 
    end

  end

  should "allow creation of help_page artefacts" do
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
