require 'test_helper'

class RummageableArtefactTest < ActiveSupport::TestCase

  setup do
    TagRepository.put tag_type: "section", tag_id: "crime", title: "Crime"
    TagRepository.put tag_type: "section", tag_id: "crime/batman", title: "Batman"
  end

  test "should extract artefact attributes" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "description" => nil,
      "section" => nil,
      "subsection" => nil
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include description" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.description = "Describe describey McDescribe"
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "description" => "Describe describey McDescribe",
      "section" => nil,
      "subsection" => nil,
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include indexable content if present" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "description" => nil,
      "section" => nil,
      "subsection" => nil,
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include section information" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
      artefact.sections = ["crime"]
      artefact.primary_section = "crime"
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "description" => nil,
      "section" => "Crime",
      "subsection" => nil,
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include subsection information" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
      artefact.sections = ["crime/batman"]
      artefact.primary_section = "crime/batman"
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "description" => nil,
      "section" => "Crime",
      "subsection" => "Batman",
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end
end
