require_relative '../../test_helper'

class ArtefactTest < ActiveSupport::TestCase

  context "#related_artefact_slugs=" do
    setup do
      @artefact = FactoryGirl.create(:artefact)
      @artefacts_to_relate = *FactoryGirl.create_list(:artefact, 2)
    end

    should "assign related artefacts based on their slugs" do
      @artefact.related_artefact_slugs = @artefacts_to_relate.map(&:slug)
      @artefact.save!

      assert_equal @artefacts_to_relate, @artefact.reload.related_artefacts
    end

    should "ignore slugs of artefacts that are not relatable" do
      archived_artefact_not_relatable = FactoryGirl.create(:artefact)
      archived_artefact_not_relatable.set(:state, "archived")
      @artefact.related_artefact_slugs = @artefacts_to_relate.map(&:slug) + [archived_artefact_not_relatable.slug]
      @artefact.save!

      assert_equal @artefacts_to_relate, @artefact.reload.related_artefacts
    end
  end

  context "#related_artefact_slugs" do
    setup do
      @artefact = FactoryGirl.create(:artefact)
      @artefact.related_artefacts = @related_artefacts = FactoryGirl.create_list(:artefact, 2)
    end

    should "should return slugs of related artefacts" do
      assert_equal @related_artefacts.map(&:slug), @artefact.related_artefact_slugs
    end
  end

end
