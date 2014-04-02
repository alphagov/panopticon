require_relative '../integration_test_helper'

class EditingTagsTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user

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

end
