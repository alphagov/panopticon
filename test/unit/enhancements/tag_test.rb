require_relative '../../test_helper'

class TagTest < ActiveSupport::TestCase
  context '#find_by_param' do
    setup do
      @tag = create(:draft_tag, tag_id: 'cake', tag_type: 'section')
      create(:draft_tag, tag_id: 'cake/sponge', tag_type: 'section', parent_id: 'cake')
    end

    should 'find a tag by its BSON ID' do
      tag = Tag.find_by_param(@tag.id)

      assert tag.present?
      assert_equal 'cake', tag.tag_id
    end

    should 'find a tag by its tag_type and tag_id' do
      tag = Tag.find_by_param('section/cake')

      assert tag.present?
      assert_equal 'cake', tag.tag_id
    end

    should 'find a child tag by its tag_type and tag_id' do
      tag = Tag.find_by_param('section/cake/sponge')

      assert tag.present?
      assert_equal 'cake/sponge', tag.tag_id
    end

    should 'raise an exception when the tag is not found' do
      # invalid tag id
      assert_raises Tag::TagNotFound do
        Tag.find_by_param('section/foo')
      end

      # without a tag id
      assert_raises Tag::TagNotFound do
        Tag.find_by_param('foo')
      end

      # too many slashes
      assert_raises Tag::TagNotFound do
        Tag.find_by_param('section//foo/bar')
      end

      # whitespace
      assert_raises Tag::TagNotFound do
        Tag.find_by_param(' ')
      end
    end
  end
end
