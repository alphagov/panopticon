require_relative '../integration_test_helper'

class ArtefactsEditTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user
    stub_all_router_api_requests
    stub_all_rummager_requests
  end

  context "editing a publisher artefact" do
    setup do
      FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "business", parent_id: nil, title: "Business")
      FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "business/employing-people", parent_id: "business", title: "Employing people")
      FactoryGirl.create(:live_tag, tag_type: "legacy_source", tag_id: "businesslink", parent_id: nil, title: "Business Link")

      @artefact = FactoryGirl.create(:artefact,
                                     name: "VAT Rates", slug: "vat-rates", kind: "answer", state: "live",
                                     owning_app: "publisher", language: "en", business_proposition: true,
                                     section_ids: ["business/employing-people"], legacy_source_ids: ["businesslink"])
    end

    should "display the artefact form" do
      visit "/artefacts/#{@artefact.id}/edit"

      within "header.artefact-header" do
        assert page.has_selector? "h1", text: "VAT Rates"
        assert page.has_link? "/vat-rates", href: "http://www.dev.gov.uk/vat-rates"
        assert page.has_selector? ".state", text: "live"
      end

      within ".artefact-actions" do
        assert page.has_selector? "li.active", text: "Edit"
        assert page.has_selector? "li:not(.active)", text: "History"
        assert page.has_selector? "li:not(.active)", text: "Archive"
      end

      within ".owning-app" do
        assert page.has_content? "This content is managed in Publisher"
        assert page.has_link? "Edit in Publisher"
      end

      within ".section-tags" do
        assert page.has_selector? ".artefact-section", count: 1

        within ".artefact-section" do
          assert page.has_select?("artefact[sections][]", selected: "Employing people")
        end
      end

      within ".form-actions" do
        assert page.has_button? "Save and continue editing"
        assert page.has_button? "Save and go to item"
      end
    end

    should "not show name or kind fields for an existing artefact" do
      visit "/artefacts/#{@artefact.id}/edit"

      assert page.has_no_field? "Name"
      assert page.has_no_field? "Kind"
    end

    should "not show slug field for a live artefact" do
      visit "/artefacts/#{@artefact.id}/edit"

      assert page.has_no_field? "Slug"
    end

    should "permit changes to the slug for a draft artefact" do
      draft_artefact = FactoryGirl.create(:artefact, state: "draft", slug: "a-pretty-slug")
      visit "/artefacts/#{draft_artefact.id}/edit"

      assert page.has_field? "Slug", with: "a-pretty-slug"
      fill_in "Slug", with: "another-slug"
      click_on "Save and continue editing"

      assert page.has_content? "Panopticon item updated"
      assert page.has_field? "Slug", with: "another-slug"
    end
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

  context "editing legacy_sources" do
    setup do
      @bl   = FactoryGirl.create(:live_tag, :tag_type => 'legacy_source', :tag_id => 'businesslink', :title => 'Business Link')
      @dg   = FactoryGirl.create(:live_tag, :tag_type => 'legacy_source', :tag_id => 'directgov', :title => 'Directgov')
      @dvla = FactoryGirl.create(:live_tag, :tag_type => 'legacy_source', :tag_id => 'dvla', :title => 'DVLA')
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

  context "editing specialist_sectors" do
    setup do
      FactoryGirl.create(:live_tag, tag_type: 'specialist_sector', tag_id: 'oil-and-gas', title: 'Oil and gas')
      FactoryGirl.create(:live_tag, tag_type: 'specialist_sector', tag_id: 'oil-and-gas/fields-and-wells', title: 'Fields and wells', parent_id: 'oil-and-gas')
      FactoryGirl.create(:live_tag, tag_type: 'specialist_sector', tag_id: 'charities', title: 'Charities')
      FactoryGirl.create(:live_tag, tag_type: 'specialist_sector', tag_id: 'charities/starting-a-charity', title: 'Starting a charity', parent_id: 'charities')

      @artefact = FactoryGirl.create(:artefact, :name => "VAT")
    end

    should "allow adding specialist sectors to artefacts" do
      visit "/artefacts"
      click_on "VAT"

      within "select#artefact_specialist_sector_ids" do
        assert page.has_selector?("optgroup[label='Oil and gas']")
        assert page.has_selector?("optgroup[label='Charities']")

        within "optgroup[label='Oil and gas']" do
          assert page.has_selector?("option", text: "Oil and gas")
          assert page.has_selector?("option", text: "Oil and gas: Fields and wells")
        end
      end

      select "Oil and gas: Fields and wells", :from => "Specialist sectors"
      select "Charities: Starting a charity", :from => "Specialist sectors"

      click_on "Save and continue editing"

      @artefact.reload
      assert_equal ["charities/starting-a-charity", "oil-and-gas/fields-and-wells"], @artefact.specialist_sector_ids.sort
    end

    should "allow removing specialist sectors from artefacts" do
      @artefact.specialist_sector_ids = ["oil-and-gas/fields-and-wells", "charities/starting-a-charity"]
      @artefact.save!

      visit "/artefacts"
      click_on "VAT"

      unselect "Oil and gas: Fields and wells", :from => "Specialist sectors"
      click_on "Save and continue editing"

      @artefact.reload
      assert_equal ["charities/starting-a-charity"], @artefact.specialist_sector_ids
    end

    context 'draft specialist sectors' do
      setup do
        create(:draft_tag, tag_type: 'specialist_sector', tag_id: 'schools-colleges', title: 'Schools and colleges')
        create(:draft_tag, tag_type: 'specialist_sector', tag_id: 'schools-colleges/academies', title: 'Academies', parent_id: 'schools-colleges')
      end

      should 'allow tagging draft specialist sectors to artefacts' do
        visit "/artefacts"
        click_on "VAT"

        within "select#artefact_specialist_sector_ids" do
          assert page.has_selector?("optgroup[label='Schools and colleges']")

          within "optgroup[label='Schools and colleges']" do
            assert page.has_selector?("option", text: "Schools and colleges")
            assert page.has_selector?("option", text: "Schools and colleges: Academies")
          end
        end

        select "Schools and colleges", :from => "Specialist sectors"
        select "Schools and colleges: Academies", :from => "Specialist sectors"

        click_on "Save and continue editing"

        @artefact.reload
        assert_equal ["schools-colleges", "schools-colleges/academies"], @artefact.specialist_sector_ids(true).sort
      end

      should 'allow removing draft specialist sectors from artefacts' do
        @artefact.specialist_sector_ids = ["schools-colleges", "schools-colleges/academies"]
        @artefact.save!

        visit "/artefacts"
        click_on "VAT"

        assert page.has_select?("Specialist sectors", selected: ["Schools and colleges", "Schools and colleges: Academies"])

        unselect "Schools and colleges: Academies", :from => "Specialist sectors"
        click_on "Save and continue editing"

        @artefact.reload
        assert_equal ["schools-colleges"], @artefact.specialist_sector_ids(true)
      end
    end
  end

  context 'editing sections' do
    setup do
      # use javascript for the section tests
      Capybara.current_driver = Capybara.javascript_driver

      FactoryGirl.create(:live_tag, tag_type: 'section', tag_id: 'visas-immigration', title: 'Visas and immigration')
      FactoryGirl.create(:live_tag, tag_type: 'section', tag_id: 'visas-immigration/student-visas', title: 'Student visas', parent_id: 'visas-immigration')

      @artefact = FactoryGirl.create(:artefact, :name => 'VAT')
    end

    should 'allow adding sections to artefacts' do
      visit "/artefacts"
      click_on "VAT"

      within '.section-tags' do
        assert page.has_selector?('div.nested-item', count: 1)

        within '.nested-item-group div:nth-of-type(1)' do
          assert page.has_select?('artefact[sections][]',
            options: ['Select a section', 'Student visas', 'Visas and immigration'],
          )

          select 'Student visas', :from => 'artefact[sections][]'
        end

        click_on 'Add another section'

        within '.nested-item-group div:nth-of-type(2)' do
          assert page.has_select?('artefact[sections][]',
            options: ['Select a section', 'Student visas', 'Visas and immigration'],
          )

          select 'Visas and immigration', :from => 'artefact[sections][]'
        end
      end

      click_on 'Save and continue editing'

      @artefact.reload

      assert_equal 'visas-immigration/student-visas', @artefact.primary_section.tag_id
      assert_equal ['visas-immigration/student-visas', 'visas-immigration'], @artefact.section_ids
    end

    should 'allow removing sections from artefacts' do
      @artefact.section_ids = ['visas-immigration/student-visas', 'visas-immigration']
      @artefact.save!

      visit '/artefacts'
      click_on 'VAT'

      within '.section-tags' do
        assert page.has_selector?('div.nested-item', count: 2)

        within '.nested-item-group div:nth-of-type(1)' do
          assert page.has_select?('artefact[sections][]',
            options: ['Select a section', 'Student visas', 'Visas and immigration'],
            selected: 'Student visas',
          )
        end

        within '.nested-item-group div:nth-of-type(2)' do
          assert page.has_select?('artefact[sections][]',
            options: ['Select a section', 'Student visas', 'Visas and immigration'],
            selected: 'Visas and immigration',
          )
        end

        # delete the first section
        within '.nested-item-group div:nth-of-type(1)' do
          click_on 'Remove this section'
        end
      end

      click_on 'Save and continue editing'

      @artefact.reload
      assert_equal 'visas-immigration', @artefact.primary_section.tag_id
      assert_equal ['visas-immigration'], @artefact.section_ids
    end

    context 'draft sections' do
      setup do
        FactoryGirl.create(:draft_tag, tag_type: 'section', tag_id: 'visas-immigration/family-visas', title: 'Family visas', parent_id: 'visas-immigration')
      end

      should 'allow tagging draft sections to artefacts' do
        visit '/artefacts'
        click_on 'VAT'

        within '.section-tags' do
          assert page.has_select?('artefact[sections][]',
            options: ['Select a section', 'Family visas', 'Student visas', 'Visas and immigration'],
          )

          select 'Family visas', :from => 'artefact[sections][]'
        end

        click_on 'Save and continue editing'

        @artefact.reload
        assert_equal ['visas-immigration/family-visas'], @artefact.section_ids(true)
      end

      should 'allow removal of draft sections from artefacts' do
        @artefact.section_ids = ['visas-immigration/student-visas', 'visas-immigration/family-visas']
        @artefact.save!

        visit '/artefacts'
        click_on 'VAT'

        within '.section-tags' do
          assert page.has_selector?('div.nested-item', count: 2)

          within '.nested-item-group div:nth-of-type(1)' do
            assert page.has_select?('artefact[sections][]',
              options: ['Select a section', 'Family visas', 'Student visas', 'Visas and immigration'],
              selected: 'Student visas',
            )
          end

          within '.nested-item-group div:nth-of-type(2)' do
            assert page.has_select?('artefact[sections][]',
              options: ['Select a section', 'Family visas', 'Student visas', 'Visas and immigration'],
              selected: 'Family visas',
            )
          end

          # delete the second (draft) section
          within '.nested-item-group div:nth-of-type(2)' do
            click_on 'Remove this section'
          end
        end

        click_on 'Save and continue editing'

        @artefact.reload
        assert_equal ['visas-immigration/student-visas'], @artefact.section_ids(true)
      end
    end
  end

  context "editing organisations" do
    setup do
      FactoryGirl.create(:live_tag, tag_type: 'organisation', tag_id: 'hm-revenue-customs', title: 'HM Revenue and Customs')
      FactoryGirl.create(:live_tag, tag_type: 'organisation', tag_id: 'driver-vehicle-licensing-agency', title: 'Driver and Vehicle Licensing Agency')
      FactoryGirl.create(:live_tag, tag_type: 'organisation', tag_id: 'cabinet-office', title: 'Cabinet Office')

      @artefact = FactoryGirl.create(:artefact, :name => "VAT")
    end

    should "allow adding organisation tags to artefacts" do
      visit "/artefacts"
      click_on "VAT"

      within "select#artefact_organisation_ids" do
        # Assert that organisations are returned in alphabetical order
        assert page.has_selector?("option:nth-of-type(1)", text: "Cabinet Office")
        assert page.has_selector?("option:nth-of-type(2)", text: "Driver and Vehicle Licensing Agency")
        assert page.has_selector?("option:nth-of-type(3)", text: "HM Revenue and Customs")
      end

      select "HM Revenue and Customs", :from => "Organisations"
      select "Cabinet Office", :from => "Organisations"

      click_on "Save and continue editing"

      @artefact.reload
      assert_equal ["cabinet-office", "hm-revenue-customs"], @artefact.organisation_ids.sort
    end

    should "allow removing organisation tags from artefacts" do
      @artefact.organisation_ids = ["cabinet-office", "hm-revenue-customs"]
      @artefact.save!

      visit "/artefacts"
      click_on "VAT"

      unselect "Cabinet Office", :from => "Organisations"
      click_on "Save and continue editing"

      @artefact.reload
      assert_equal ["hm-revenue-customs"], @artefact.organisation_ids
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

  context "relating artefacts" do
    context "without javascript" do
      setup do
        @artefact = FactoryGirl.create(:artefact)
        @artefacts_to_relate = *FactoryGirl.create_list(:artefact, 2)
      end

      should "be done by entering slugs of artefacts to relate" do
        visit edit_artefact_path(@artefact)

        fill_in "Related artefact slugs", with: @artefacts_to_relate.map(&:slug).join(", ")
        click_on "Save and continue editing"

        assert_equal @artefacts_to_relate.map(&:slug).join(", "), find_field("Related artefact slugs").value
      end
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
      within ".related-external-links" do
        fill_in "Title", :with => "BBC", :match => :first
        fill_in "URL", :with => "http://bbc.co.uk", :match => :first
      end

      click_on "Save and continue editing"
      @artefact.reload
      assert_equal 1, @artefact.external_links.length
      assert_equal "BBC", @artefact.external_links.first.title
    end

  end
end
