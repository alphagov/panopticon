require 'test_helper'

class ArtefactSearchIndexingTest < ActiveSupport::TestCase
  setup do
    stub_all_router_api_requests
    @dapaas_tag = Tag.new(tag_type: "role", tag_id: "dapaas", title: "dapaas")
    @odi_tag = Tag.new(tag_type: "role", tag_id: "odi", title: "odi")
  end

  context "with dapaas artefacts" do
    setup do
      @artefact = FactoryGirl.create(:artefact, roles:[@dapaas_tag.tag_id])
    end

    should "set indexable_content on artefacts" do
      @artefact.indexable_content = "Searchy searchy McSearch"
      assert_equal "Searchy searchy McSearch", @artefact.indexable_content
    end

    should "not persist indexable content" do
      @artefact.indexable_content = "Searchy searchy McSearch"
      @artefact.save

      reloaded_artefact = Artefact.find(@artefact.id)
      assert_nil reloaded_artefact.indexable_content
    end

    should "submit live artefacts to the search index" do
      RummageableArtefact.any_instance.expects(:submit)
      @artefact.state = "live"
      @artefact.save!
    end

    should "delete archived artefacts from the search index" do
      RummageableArtefact.any_instance.expects(:delete)
      @artefact.state = "archived"
      @artefact.save!
    end

    should "delete live artefacts changing to an unindexed kind" do
      RummageableArtefact.any_instance.stubs(:submit)
      artefact = FactoryGirl.create(:artefact, kind: "answer", state: "live", roles:[@dapaas_tag.tag_id])

      RummageableArtefact.any_instance.expects(:delete)
      artefact.kind = "completed_transaction"
      artefact.save!
    end

  end

  context "with odi artefacts" do
    setup do
      @artefact = FactoryGirl.create(:artefact, roles:[@odi_tag.tag_id])
    end

    should "set indexable_content on artefacts" do
      @artefact.indexable_content = "Searchy searchy McSearch"
      assert_equal "Searchy searchy McSearch", @artefact.indexable_content
    end

    should "not persist indexable content" do
      @artefact.indexable_content = "Searchy searchy McSearch"
      @artefact.save

      reloaded_artefact = Artefact.find(@artefact.id)
      assert_nil reloaded_artefact.indexable_content
    end

    should "submit live artefacts to the search index" do
      RummageableArtefact.any_instance.expects(:submit)
      @artefact.state = "live"
      @artefact.save!
    end

    should "delete archived artefacts from the search index" do
      RummageableArtefact.any_instance.expects(:delete)
      @artefact.state = "archived"
      @artefact.save!
    end

    should "delete live artefacts changing to an unindexed kind" do
      RummageableArtefact.any_instance.stubs(:submit)
      artefact = FactoryGirl.create(:artefact, kind: "answer", state: "live", roles:[@odi_tag.tag_id])

      RummageableArtefact.any_instance.expects(:delete)
      artefact.kind = "completed_transaction"
      artefact.save!
    end
  end

  context "with multiple roles" do
    setup do
      @artefact = FactoryGirl.create(:artefact, roles:[@dapaas_tag.tag_id, @odi_tag.tag_id])
    end

    should "set indexable_content on artefacts" do
      @artefact.indexable_content = "Searchy searchy McSearch"
      assert_equal "Searchy searchy McSearch", @artefact.indexable_content
    end

    should "not persist indexable content" do
      @artefact.indexable_content = "Searchy searchy McSearch"
      @artefact.save

      reloaded_artefact = Artefact.find(@artefact.id)
      assert_nil reloaded_artefact.indexable_content
    end

    should "submit live artefacts to the search index" do
      RummageableArtefact.any_instance.expects(:submit)
      @artefact.state = "live"
      @artefact.save!
    end

    should "delete archived artefacts from the search index" do
      RummageableArtefact.any_instance.expects(:delete)
      @artefact.state = "archived"
      @artefact.save!
    end

    should "delete live artefacts changing to an unindexed kind" do
      RummageableArtefact.any_instance.stubs(:submit)
      artefact = FactoryGirl.create(:artefact, kind: "answer", state: "live", roles:[@dapaas_tag.tag_id, @odi_tag.tag_id])

      RummageableArtefact.any_instance.expects(:delete)
      artefact.kind = "completed_transaction"
      artefact.save!
    end
  end
end
