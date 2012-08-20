require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "link to the live site from the edit form" do
    artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_link?("View on site", :href => "http://www.test.gov.uk/alpha")
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
      assert_equal [@bl, @dvla], @a.legacy_sources
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
end
