require 'test_helper'

class TagRepositoryTest < ActiveSupport::TestCase

  setup do
    TagRepository.put(:tag_id => 'crime', :tag_type => 'section',
                      :title => 'Crime')
    TagRepository.put(:tag_id => 'crime/the-police', :tag_type => 'section',
                      :title => 'The Police')
    TagRepository.put(:tag_id => 'cheese', :tag_type => 'keyword',
                      :title => 'Cheese')
  end

  test "should return all tags" do
    assert_equal TagRepository.load_all.map { |t| t.tag_id }.sort,
                 ['cheese', 'crime', 'crime/the-police']
  end

  test "should filter tags by type" do
    section_tags = TagRepository.load_all(:tag_type => 'section')
    assert_equal section_tags.map { |t| t.tag_id }.sort,
                 ['crime', 'crime/the-police']
  end

  test "should return empty list when no tags" do
    assert_equal TagRepository.load_all(:tag_type => 'weevil').count, 0
  end

end
