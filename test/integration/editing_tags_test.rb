require_relative '../integration_test_helper'

class EditingTagsTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user

    # stub the router + rummager requests so that artefact creation doesn't
    # fire off a bunch of web requests
    stub_all_router_api_requests
    stub_all_rummager_requests

    @tag = create(:tag, tag_type: 'section',
                        tag_id: 'driving',
                        title: 'Driving',
                        description: 'Car tax, MOTs and driving licences')
  end

  should 'display the form for an existing tag' do
    visit edit_tag_path(@tag)

    within "header.artefact-header" do
      assert page.has_content?('Section: Driving')
      assert page.has_link?('/browse/driving', href: 'http://www.dev.gov.uk/browse/driving')
    end

    within 'form' do
      assert page.has_field?('Title', with: @tag.title)

      # Include a trailing newline in the assertion, as Rails inserts this into
      # text area tags before the value
      assert page.has_field?('Description', with: "\n#{@tag.description}")

      assert page.has_button?('Save this section')
    end
  end

  should 'display errors when a tag cannot be saved' do
    visit edit_tag_path(@tag)

    fill_in 'Title', with: ''
    click_on 'Save this section'

    assert page.has_content? "Title can't be blank"
  end

  should 'display a notice when the tag is saved' do
    visit edit_tag_path(@tag)

    click_on 'Save this section'

    assert page.has_content? 'Tag has been updated'
  end

  should 'show the curated list for a tag' do
    child_tag = create(:tag, title: 'MOT',
                             tag_id: 'driving/mot',
                             tag_type: 'section',
                             parent_id: 'driving')
    artefacts = create_list(:live_artefact, 5, kind: 'answer',
                                               section_ids: [child_tag.tag_id])
    curated_list = create(:curated_list, slug: child_tag.tag_id.gsub('/','-'),
                                         tag_ids: [child_tag.tag_id],
                                         artefact_ids: artefacts.map(&:id))

    visit edit_tag_path(child_tag)

    within ".curated-artefact-group" do
      assert page.has_selector?('.curated-artefact', count: 5)

      artefacts.each_with_index do |artefact, i|
        selector = ".curated-artefact:nth-of-type(#{i+1})"

        within(selector) do
          assert page.has_select?('curated_list[artefact_ids][]', selected: artefact.name)
          assert page.has_button?('Remove curated item')
        end
      end
    end

    assert page.has_button?('Add another artefact')
  end

end
