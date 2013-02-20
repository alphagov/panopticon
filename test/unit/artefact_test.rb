require 'test_helper'

class ArtefactTest < ActiveSupport::TestCase
  def swallow_router_requests
    stub_request(:any, %r{http://router.cluster:8080/router/.*}).to_return(:status => 200, :body => "{}")
  end

  setup do
    swallow_router_requests
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
end
