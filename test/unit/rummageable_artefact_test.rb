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
    FactoryGirl.create(:draft_tag, tag_type: "specialist_sector", tag_id: "working-sea/training-certification", title: "Training and certification",
                       parent_id: "working-sea")
  end

  def assert_hash_including(expected_hash, actual_hash)
    expected_hash.each do |expected_key, expected_value|
      assert_equal expected_value, actual_hash[expected_key]
    end
  end

  test "should extract artefact attributes" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide"
    )
    # Note: the link is not present if we are amending
    expected = {
      "title" => "My artefact",
      "format" => "guide",
      "organisations" => [],
      "specialist_sectors" => [],
    }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash.merge(bla: 'akjd')
  end

  test "should include description" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide",
      description: "Describe describey McDescribe"
    )
    # Note: the link is not present if we are amending
    expected = {
      "title" => "My artefact",
      "format" => "guide",
      "description" => "Describe describey McDescribe",
      "organisations" => [],
      "specialist_sectors" => [],
    }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include indexable content if present" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide",
      indexable_content: "Blah blah blah index this"
    )
    # Note: the link is present if we are not amending
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
      "specialist_sectors" => [],
    }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include latest_change_note and public_timestamp if present" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide",
      latest_change_note: "Something has changed",
      public_timestamp: Time.zone.parse('2014-01-01 12:00:00 +00:00')
    )
    # Note: the link is present if we are not amending
    expected = {
      "title" => "My artefact",
      "format" => "guide",
      "organisations" => [],
      "specialist_sectors" => [],
      "public_timestamp" => "2014-01-01T12:00:00+00:00",
      "latest_change_note" => "Something has changed",
    }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should work with no primary section" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide",
      indexable_content: "Blah blah blah index this",
      sections: []
    )
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "indexable_content" => "Blah blah blah index this",
      "organisations" => [],
    }
  end

  test "should include organisations" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide",
      indexable_content: "Blah blah blah index this",
      organisation_ids: ["cabinet-office", "department-for-transport"]
    )
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "organisations" => [
        "cabinet-office",
        "department-for-transport"
      ],
      "specialist_sectors" => [],
      "indexable_content" => "Blah blah blah index this"
    }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include live specialist sectors" do
    artefact = Artefact.new(
      name: "My artefact",
      slug: "my-artefact",
      kind: "guide",
      indexable_content: "Blah blah blah index this",
      organisation_ids: [],
      specialist_sectors: [
        'oil-and-gas/licensing',
        'working-sea/health-safety',
        'working-sea/training-certification'
      ]
    )
    expected = {
      "link" => "/my-artefact",
      "title" => "My artefact",
      "format" => "guide",
      "organisations" => [],
      "specialist_sectors" => [
        'oil-and-gas/licensing',
        'working-sea/health-safety'
        # Deliberately missing draft tag 'working-sea/training-certification'
      ],
      "indexable_content" => "Blah blah blah index this"
    }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include live mainstream browse pages" do
    FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "a-browse-page-tag")

    artefact = Artefact.new(
      sections: [
        'a-browse-page-tag',
      ]
    )

    expected = { "mainstream_browse_pages" => ['a-browse-page-tag'] }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should include live second-level mainstream browse pages" do
    parent_section = FactoryGirl.create(:live_tag, tag_id: "parent-browse-page", tag_type: "section")
    FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "parent-browse-page/a-browse-page-tag", parent_id: parent_section.tag_id)

    artefact = Artefact.new(
      sections: [
        'parent-browse-page/a-browse-page-tag',
      ]
    )

    expected = { "mainstream_browse_pages" => ['parent-browse-page/a-browse-page-tag'] }
    assert_hash_including expected, RummageableArtefact.new(artefact).artefact_hash
  end

  test "should consider live items should be indexed" do
    artefact = Artefact.new(
      state: "live"
    )

    assert RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should not index business support content" do
    artefact = Artefact.new(
      state: "live",
      kind: "business_support"
    )

    refute RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should index business support content with an acceptable slug" do
    artefact = Artefact.new(
      slug: "new-enterprise-allowance",
      state: "live",
      kind: "business_support"
    )

    assert RummageableArtefact.new(artefact).should_be_indexed?
  end

  should "index campaigns with an acceptable slug" do
    artefact = Artefact.new(
      slug: "unimoney",
      state: "live",
      kind: "campaign"
    )

    assert RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should not index content formats managed by Whitehall" do
    artefact = Artefact.new(
      state: "live",
      kind: Artefact::FORMATS_BY_DEFAULT_OWNING_APP["whitehall"].first
    )

    refute RummageableArtefact.new(artefact).should_be_indexed?
  end

  test "should not index content formats managed by Specialist publisher" do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["specialist-publisher"].each do |kind|
      artefact = Artefact.new(
        state: "live",
        kind: kind
      )

      refute RummageableArtefact.new(artefact).should_be_indexed?
    end
  end

  test "should not index content formats managed by Finder api" do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["finder-api"].each do |kind|
      artefact = Artefact.new(
        state: "live",
        kind: kind
      )

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
