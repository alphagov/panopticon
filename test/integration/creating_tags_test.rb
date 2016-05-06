require_relative '../integration_test_helper'

class CreatingTagsTest < ActionDispatch::IntegrationTest

  setup do
    login_as_user_with_permission('manage_tags')
  end

  should 'create a parent tag given valid parameters' do
    params = {
      tag_id: 'driving',
      tag_type: 'section',
      title: 'Driving',
    }
    post_json tags_path, params

    assert_equal 201, response.status

    tag = Tag.by_tag_id('driving', type: 'section', draft: true)
    assert tag.present?

    assert_equal 'Driving', tag.title
    assert_equal nil, tag.parent_id
  end

  should 'create a child tag given valid parameters' do
    parent_tag = create(:draft_tag, tag_id: 'driving', tag_type: 'section')

    params = {
      tag_id: 'driving/car-tax',
      tag_type: 'section',
      title: 'Car tax',
      parent_id: 'driving',
    }
    post_json tags_path, params

    assert_equal 201, response.status

    tag = Tag.by_tag_id('driving/car-tax', type: 'section', draft: true)
    assert tag.present?

    assert_equal 'Car tax', tag.title
    assert_equal 'driving', tag.parent_id
  end

  should 'return errors given invalid parameters' do
    params = {
      tag_id: 'foo/bar/baz',
      tag_type: nil,
      title: 'Driving',
    }
    post_json tags_path, params
    body = JSON.parse(response.body)

    assert_equal 422, response.status
    assert_match /can't be blank/, body['errors']['tag_type'].first
    assert_match /must be valid/, body['errors']['tag_id'].first
  end
end
