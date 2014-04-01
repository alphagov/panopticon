require_relative '../integration_test_helper'

class CreatingTagsTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should 'display the form' do
    visit new_tag_path

    within 'form' do
      assert page.has_select?('Type', with_options: ['', 'Section', 'Specialist sector'], selected: nil)

      assert page.has_field?('Title', with: nil)
      assert page.has_field?('Slug', with: nil)
      assert page.has_field?('Description', with: nil)

      assert page.has_no_field?('Parent')

      assert page.has_button?('Create tag')
    end
  end

  should 'pre-select a tag type specified in the url' do
    visit new_tag_path(type: "section")

    assert page.has_select?('Type', selected: 'Section')
  end

  should 'prepare fields given a parent id and tag type in the url' do
    visit new_tag_path(type: 'section', parent_id: 'business')

    assert page.has_select?('Type', selected: 'Section')
    assert page.has_field?('Slug', with: 'business/')

    parent_field = find_field("Parent")
    assert_equal 'business', parent_field[:value]
    assert_equal 'disabled', parent_field[:disabled]
  end

end
