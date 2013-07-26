require 'test_helper'

class RummageableArtefactTest < ActiveSupport::TestCase

  setup do
    FactoryGirl.create(:tag, tag_type: "section", tag_id: "crime", title: "Crime")
    FactoryGirl.create(:tag, tag_type: "section", tag_id: "crime/batman", title: "Batman", parent_id: "crime")
  end

  test "should extract artefact attributes" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
    end
    # Note: the link is not present if we are amending
    expected = {
      "title" => "My artefact",
      "format" => "guide",
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
    # Note: the link is not present if we are amending
    expected = {
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
    # Note: the link is present if we are not amending
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "section" => nil,
      "subsection" => nil,
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should work with no primary section" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
      artefact.sections = []
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "section" => nil,
      "subsection" => nil,
      "indexable_content" => "Blah blah blah index this"
    }
  end

  test "should include section information" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
      artefact.sections = ["crime"]
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "section" => "crime",
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
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "section" => "crime",
      "subsection" => "batman",
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should fake section information for travel advice format" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "travel-advice"
      artefact.indexable_content = "Blah blah blah index this"
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "travel-advice",
      "section" => "foreign-travel-advice",
      "subsection" => nil,
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should consider live items should be indexed" do
    artefact = Artefact.new do |artefact|
      artefact.state = "live"
    end

    assert RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should not index business support content" do
    artefact = Artefact.new do |artefact|
      artefact.state = "live"
      artefact.kind = "business_support"
    end

    refute RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should index business support content with an acceptable slug" do
    artefact = Artefact.new do |artefact|
      artefact.slug = "new-enterprise-allowance"
      artefact.state = "live"
      artefact.kind = "business_support"
    end

    assert RummageableArtefact.new(artefact).should_be_indexed?
  end

end
