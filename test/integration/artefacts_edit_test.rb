require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "link to the live site from the edit form" do
    artefact = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_link?("View on site", :href => "http://www.#{ENV["GOVUK_APP_DOMAIN"]}/alpha")
  end

  # skip all these tests, odi does not make use of needs
  context "linking to needs" do
    should "link to the Needotron given a need ID < 100000" do
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :name => "Need from Needotron", :slug => 'needotron', :need_id => "99999")

      visit "/artefacts"
      click_on "Need from Needotron"

      assert page.has_link?("View in Needotron", :href => "http://needotron.dev.gov.uk/needs/99999")
    end

    should "link to Maslow given a need ID >= 100000" do
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :name => "Need from Maslow", :slug => 'maslow', :need_id => "100000")

      visit "/artefacts"
      click_on "Need from Maslow"

      assert page.has_link?("View in Maslow", :href => "http://maslow.dev.gov.uk/needs/100000")
    end

    should "not link to any need if the need ID is non-numeric" do
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :name => "Need from a spreadsheet", :slug => 'spreadsheet', :need_id => "B12345")

      visit "/artefacts"
      click_on "Need from a spreadsheet"

      assert page.has_no_link?("View in Needotron")
      assert page.has_no_link?("View in Maslow")
    end
  end

  # skipping all these tests, odi does not make use of needs
  context "linking to needs" do
    should "link to the Needotron given a need ID < 100000" do
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :name => "Need from Needotron", :slug => 'needotron', :need_id => "99999")

      visit "/artefacts"
      click_on "Need from Needotron"

      assert page.has_link?("View in Needotron", :href => "http://needotron.dev.gov.uk/needs/99999")
    end

    should "link to Maslow given a need ID >= 100000" do
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :name => "Need from Maslow", :slug => 'maslow', :need_id => "100000")

      visit "/artefacts"
      click_on "Need from Maslow"

      assert page.has_link?("View in Maslow", :href => "http://maslow.dev.gov.uk/needs/100000")
    end

    should "not link to any need if the need ID is non-numeric" do
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :name => "Need from a spreadsheet", :slug => 'spreadsheet', :need_id => "B12345")

      visit "/artefacts"
      click_on "Need from a spreadsheet"

      assert page.has_no_link?("View in Needotron")
      assert page.has_no_link?("View in Maslow")
    end
  end

  # skipping all these tests, odi does not make use of needs
  context "restricting editing of need_id" do
    should "not allow editing if it looks like a Maslow need >= 100000" do
      skip("we do not care about needs. Form is disabled.")
      visit "/artefacts/#{artefact.id}/edit"
      field = page.find_field("Need")
      assert field[:disabled]
    end

    should "allow editing if blank" do
      skip("we do not care about needs. Form is disabled.")
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
      skip("we do not care about needs. Form is disabled.")
      artefact = FactoryGirl.create(:artefact, :need_id => "B241")
      visit "/artefacts/#{artefact.id}/edit"
      field = page.find_field("Need")
      assert field[:disabled].nil?

      fill_in "Need", :with => "2345"
      click_on "Save and continue editing"

      artefact.reload
      assert_equal "2345", artefact.need_id
    end

    should "allow editing if it looks like a Need-o-tron need < 100000" do
      artefact = FactoryGirl.create(:artefact, :need_id => "99999")
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
      assert_equal 2, @a.legacy_sources.count
      assert @a.legacy_sources.include?(@dvla)
      assert @a.legacy_sources.include?(@bl)
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

  should "not include completed transactions in related item lists" do
    a = FactoryGirl.create(:artefact, :name => "Alpha", :slug => 'alpha')
    b = FactoryGirl.create(:artefact, :name => "Beta", :slug => 'beta')
    c = FactoryGirl.create(:artefact, :name => "Done", :slug => 'done/completed-example', :kind => 'completed_transaction')

    visit "/artefacts"
    click_on "Alpha"

    assert page.has_selector?("#artefact_related_artefact_ids_ option[value='#{b.id}']")
    assert ! page.has_selector?("#artefact_related_artefact_ids_ option[value='#{c.id}']")
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
