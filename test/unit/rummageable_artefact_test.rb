require 'test_helper'

class RummageableArtefactTest < ActiveSupport::TestCase

  setup do
    FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "crime", title: "Crime")
    FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "crime/batman", title: "Batman", parent_id: "crime")

    FactoryGirl.create(:live_tag, tag_type: "organisation", tag_id: "cabinet-office", title: "Cabinet Office")
    FactoryGirl.create(:live_tag, tag_type: "organisation", tag_id: "department-for-transport", title: "Department for Transport")

    FactoryGirl.create(:live_tag, tag_type: "specialist_sector", tag_id: "oil-and-gas", title: "Oil and Gas")
    FactoryGirl.create(:live_tag, tag_type: "specialist_sector", tag_id: "oil-and-gas/licensing", title: "Licensing",
                       parent_id: "oil-and-gas")

    FactoryGirl.create(:live_tag, tag_type: "specialist_sector", tag_id: "working-sea", title: "Working at sea")
    FactoryGirl.create(:live_tag, tag_type: "specialist_sector", tag_id: "working-sea/health-safety", title: "Health and safety",
                       parent_id: "working-sea")
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
      "subsection" => nil,
      "organisations" => [],
      "specialist_sectors" => [],
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
      "organisations" => [],
      "specialist_sectors" => [],
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
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
      "specialist_sectors" => [],
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
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
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
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
      "specialist_sectors" => [],
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
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
      "specialist_sectors" => [],
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
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
      "specialist_sectors" => [],
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include organisations" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
      artefact.organisation_ids = ["cabinet-office", "department-for-transport"]
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "subsection" => nil,
      "section" => nil,
      "organisations" => [
        "cabinet-office",
        "department-for-transport"
      ],
      "specialist_sectors" => [],
      "indexable_content" => "Blah blah blah index this"
    }
    assert_equal expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include specialist sectors" do
    artefact = Artefact.new do |artefact|
      artefact.name = "My artefact"
      artefact.slug = "my-artefact"
      artefact.kind = "guide"
      artefact.indexable_content = "Blah blah blah index this"
      artefact.organisation_ids = []
      artefact.specialist_sectors = [
        'oil-and-gas/licensing',
        'working-sea/health-safety'
      ]
    end
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "subsection" => nil,
      "section" => nil,
      "organisations" => [],
      "specialist_sectors" => [
        'oil-and-gas/licensing',
        'working-sea/health-safety'
      ],
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

  test "should not index content formats managed by Whitehall" do
    artefact = Artefact.new do |artefact|
      artefact.state = "live"
      artefact.kind = Artefact::FORMATS_BY_DEFAULT_OWNING_APP["whitehall"].first
    end

    refute RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should not index content formats managed by Specialist publisher" do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["specialist-publisher"].each do |kind|
      artefact = Artefact.new do |artefact|
        artefact.state = "live"
        artefact.kind = kind
      end

      refute RummageableArtefact.new(artefact).should_be_indexed?
    end
  end

  test "should not index content formats managed by Finder api" do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["finder-api"].each do |kind|
      artefact = Artefact.new do |artefact|
        artefact.state = "live"
        artefact.kind = kind
      end

      refute RummageableArtefact.new(artefact).should_be_indexed?
    end
  end

  test "adds a rummageable artefact with indexable content to the search index" do
    artefact = build(:artefact, indexable_content: "blah")
    rummageable_artefact = RummageableArtefact.new(artefact)

    stub_search_index = stub("Rummageable::Index")
    SearchIndex.expects(:instance).returns(stub_search_index)

    stub_search_index.expects(:add).with(rummageable_artefact.artefact_hash)
    rummageable_artefact.submit
  end

  test "amends a rummageable artefact without indexable content" do
    artefact = build(:artefact, indexable_content: nil)
    rummageable_artefact = RummageableArtefact.new(artefact)

    stub_search_index = stub("Rummageable::Index")
    SearchIndex.expects(:instance).returns(stub_search_index)

    stub_search_index.expects(:amend).with(rummageable_artefact.artefact_link,
                                           rummageable_artefact.artefact_hash)
    rummageable_artefact.submit
  end

  test "deletes a rummageable artefact" do
    artefact = build(:artefact)
    rummageable_artefact = RummageableArtefact.new(artefact)

    stub_search_index = stub("Rummageable::Index")
    SearchIndex.expects(:instance).returns(stub_search_index)

    stub_search_index.expects(:delete).with(rummageable_artefact.artefact_link)
    stub_search_index.expects(:commit)

    rummageable_artefact.delete
  end
end
