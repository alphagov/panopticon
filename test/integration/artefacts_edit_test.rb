require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "link to the live site from the edit form" do
    artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_link?("View on site", :href => "http://www.dev.gov.uk/alpha")
  end

  context "restricting editing of need_id" do
    should "not allow editing with existing numeric value" do
      artefact = FactoryGirl.create(:artefact, :need_id => "1234")
      visit "/artefacts/#{artefact.id}/edit"
      field = page.find_field("Need")
      assert field[:disabled]
    end

    should "allow editing if blank" do
      artefact = FactoryGirl.create(:artefact, :need_id => " ")
      visit "/artefacts/#{artefact.id}/edit"
      field = page.find_field("Need")
      assert field[:disabled].nil?

      fill_in "Need", :with => "2345"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal "2345", artefact.need_id
    end

    should "allow editing if non-numeric" do
      artefact = FactoryGirl.create(:artefact, :need_id => "B241")
      visit "/artefacts/#{artefact.id}/edit"
      field = page.find_field("Need")
      assert field[:disabled].nil?

      fill_in "Need", :with => "2345"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal "2345", artefact.need_id
    end
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

  context "related external links" do
    setup do
      Capybara.current_driver = Capybara.javascript_driver
      @artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => "alpha")
    end

    should "be able to add related external links" do
      visit "/artefacts"
      click_on "Alpha"
      click_on "Add related external link"
      within ".related-external-links div:first-child" do
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
