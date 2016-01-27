require 'test_helper'

class ArtefactSearchIndexingTest < ActiveSupport::TestCase
  setup do
    stub_all_router_api_requests
    @artefact = FactoryGirl.create(:artefact)
  end

  test "should set indexable_content on artefacts" do
    @artefact.indexable_content = "Searchy searchy McSearch"
    assert_equal "Searchy searchy McSearch", @artefact.indexable_content
  end

  test "should not persist indexable content" do
    @artefact.indexable_content = "Searchy searchy McSearch"
    @artefact.save

    reloaded_artefact = Artefact.find(@artefact.id)
    assert_nil reloaded_artefact.indexable_content
  end

  test "should submit live artefacts to the search index" do
    RummageableArtefact.any_instance.expects(:submit)
    @artefact.state = "live"
    @artefact.save!
  end

  test "should delete archived artefacts from the search index" do
    RummageableArtefact.any_instance.expects(:delete)
    @artefact.state = "archived"
    @artefact.save!
  end

  test "should delete live artefacts changing to an unindexed kind" do
    RummageableArtefact.any_instance.stubs(:submit)
    @artefact = FactoryGirl.create(:artefact, kind: "answer", state: "live")

    RummageableArtefact.any_instance.expects(:delete)
    @artefact.kind = "completed_transaction"
    @artefact.save!
  end

  test "should not delete an artefact with an excluded kind where the slug is indexable" do
    RummageableArtefact.any_instance.stubs(:submit)
    @artefact = FactoryGirl.create(:artefact, kind: "answer", slug: "new-enterprise-allowance", state: "live")

    RummageableArtefact.any_instance.expects(:submit)
    RummageableArtefact.any_instance.expects(:delete).never
    @artefact.kind = "business_support"
    @artefact.save!
  end

  test "should request an amend to the search index, with a slug and an hash of the artefact attributes to be indexed" do
    FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "a-section", title: "A Section")
    FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "a-section/subsection", title: "A Subsection", parent_id: "a-section")
    FactoryGirl.create(:live_tag, tag_type: "organisation", tag_id: "cabinet-office", title: "Cabinet Office")
    FactoryGirl.create(:live_tag, tag_type: "specialist_sector", tag_id: "working-sea", title: "Working at sea")
    FactoryGirl.create(:live_tag, tag_type: "specialist_sector", tag_id: "working-sea/health-safety", title: "Health and safety",
                       parent_id: "working-sea")

    new_artefact = FactoryGirl.build(
      :artefact,
      name: "My artefact",
      sections: ["a-section/subsection"],
      slug: "my-artefact",
      kind: "guide", state: "live",
      organisations: ["cabinet-office"],
      specialist_sectors: ["working-sea/health-safety"]
    )

    expected_hash_of_attributes_to_index = {
      "title" => "My artefact",
      "format" => "guide",
      "organisations" => ["cabinet-office"],
      "specialist_sectors" => ["working-sea/health-safety"],
      "mainstream_browse_pages" => ["a-section/subsection"],
    }

    mock_search_index = mock
    SearchIndex.stubs(:instance).returns(mock_search_index)
    mock_search_index.expects(:amend).with("/#{new_artefact['slug']}", expected_hash_of_attributes_to_index)

    new_artefact.save!
  end
end
