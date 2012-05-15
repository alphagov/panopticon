require 'test_helper'

TEST_SECTIONS = [['crime', 'Crime'], ['crime/the-police', 'The Police'],
                 ['crime/batman', 'Batman']]
TEST_KEYWORDS = [['cheese', 'Cheese'], ['bacon', 'Bacon']]

class ArtefactTagTest < ActiveSupport::TestCase

  setup do
    TEST_SECTIONS.each do |tag_id, title|
      TagRepository.put(:tag_id => tag_id, :tag_type => 'section', :title => title)
    end
    TEST_KEYWORDS.each do |tag_id, title|
      TagRepository.put(:tag_id => tag_id, :tag_type => 'keyword', :title => title)
    end
  end

  test "can set sections" do
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => 'x')
    a.sections = ['crime', 'crime/the-police']
    assert_equal ['crime', 'crime/the-police'], a.tag_ids, 'Mismatched tags'
    assert_equal ['crime', 'crime/the-police'], a.sections, 'Mismatched sections'
  end

  test "cannot set non-existent sections" do
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => 'x')
    assert_raise { a.sections = ['weevils']}
  end

  test "cannot set non-section tags" do
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => 'x')
    assert_raise { a.sections = ['crime', 'bacon']}
  end

  test "can set no sections" do
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => 'x')
    a.sections = ['crime', 'crime/the-police']
    a.sections = []
    assert_equal a.sections, []
  end

  test "setting sections doesn't break other tags" do
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => 'x')
    a.tag_ids = ['cheese', 'bacon']
    a.sections = ['crime']
    assert_equal a.tag_ids.sort, ['bacon', 'cheese', 'crime']
  end

  test "can prepend tags" do
    # A bug in earlier versions of the mongoid library meant it would try to be
    # a little too clever dealing with arrays, and in so doing would process
    # modified arrays as $pushAll operators, breaking the array's ordering
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => 'x')
    a.tag_ids = ['crime', 'crime/the-police']
    a.save
    a.reload
    assert_equal a.tag_ids, ['crime', 'crime/the-police']

    a.tag_ids = ['crime/batman'] + a.sections
    assert_equal a.tag_ids, ['crime/batman', 'crime', 'crime/the-police']
    a.save
    a.reload
    assert_equal a.tag_ids, ['crime/batman', 'crime', 'crime/the-police']
  end

  test "can obtain primary section" do
    a = Artefact.create!(:slug => "a", :name => "a", :kind => "answer",
                         :need_id => 1, :owning_app => "x",
                         :tag_ids => ['cheese', 'crime/the-police', 'crime/batman'])
    assert_equal a.primary_section, "crime/the-police"
  end

end
