require_relative '../integration_test_helper'

class CreatingTagsTest < ActionDispatch::IntegrationTest

  setup do
    login_as_user_with_permission('manage_tags')
  end

  should 'display the form' do
    visit new_tag_path

    within 'form' do
      assert page.has_select?('Type', with_options: ['', 'Section', 'Specialist sector'], selected: [])

      assert page.has_field?('Title', with: nil)
      assert page.has_field?('Slug', with: nil)
      assert page.has_field?('Description', with: '')

      assert page.has_no_field?('Parent')

      assert page.has_button?('Create tag')
    end
  end

  should 'pre-select a tag type specified in the url' do
    visit new_tag_path(type: "section")

    assert_equal "section", page.field_labeled('Type', disabled: true).value
  end

  should 'prepare fields given a parent id and tag type in the url' do
    visit new_tag_path(type: 'section', parent_id: 'business')

    assert_equal "section", page.field_labeled('Type', disabled: true).value

    within ".child_tag_id" do
      assert page.has_content?('business/')
      assert page.has_field?('Slug', with: nil)
    end

    assert field_labeled("Parent", disabled: true, with: 'business').present?
  end

  should 'display errors when a tag cannot be saved' do
    visit new_tag_path

    click_on 'Create tag'

    assert page.has_content? "Title can't be blank"
  end

  should 'display a notice when the tag is saved' do
    visit new_tag_path

    select 'Section', from: 'Type'
    fill_in 'Title', with: "Driving"
    fill_in 'Slug', with: 'driving'

    click_on 'Create tag'

    assert page.has_content? 'Tag has been created'
  end

end
