require_relative '../../test_helper'

class ArtefactTest < ActiveSupport::TestCase

  context "#related_artefact_slugs=" do
    setup do
      @artefact = FactoryGirl.create(:artefact)
      @artefacts_to_relate = *FactoryGirl.create_list(:artefact, 2)
    end

    should "assign related_artefact_ids based on their slugs" do
      @artefact.related_artefact_slugs = @artefacts_to_relate.map(&:slug)
      @artefact.save!

      assert_equal @artefacts_to_relate.map(&:_id), @artefact.reload.related_artefact_ids
    end

    should "ignore slugs of artefacts that are not relatable" do
      archived_artefact_not_relatable = FactoryGirl.create(:artefact)
      archived_artefact_not_relatable.set(state: "archived")
      @artefact.related_artefact_slugs = @artefacts_to_relate.map(&:slug) + [archived_artefact_not_relatable.slug]
      @artefact.save!

      assert_equal @artefacts_to_relate.map(&:_id), @artefact.reload.related_artefact_ids
    end

    should "keep order of related_artefact_ids same as related_artefact_slugs" do
      @artefact.related_artefact_slugs = @artefacts_to_relate.reverse.map(&:slug)
      @artefact.save!

      assert_equal @artefacts_to_relate.reverse.map(&:_id), @artefact.reload.related_artefact_ids
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

  context ".relatable_items_like" do
    should "should return relatable artefacts that begin with the title substring" do
      relatable_artefact_one = FactoryGirl.create(:artefact, name: "Benefits calculator")
      relatable_artefact_two = FactoryGirl.create(:artefact, name: "Child tax benefits")

      # archived artefact not relatable
      FactoryGirl.create(:artefact, name: "Benefit for all").set(state: "archived")
      # relatable artefact not matching
      FactoryGirl.create(:artefact, name: "Tax credits")

      assert_equal [relatable_artefact_one], Artefact.relatable_items_like("benefit")
    end
  end

  context '#allow_specialist_sector_tag_changes?' do
    should 'be true for a non-whitehall non-publisher artefact' do
      artefact = FactoryGirl.build(:artefact, owning_app: 'smartanswers')

      assert artefact.allow_specialist_sector_tag_changes?
    end

    should 'be false for a whitehall artefact' do
      artefact = FactoryGirl.build(:whitehall_draft_artefact)

      assert_equal false, artefact.allow_specialist_sector_tag_changes?
    end

    should 'be false for a publisher artefact' do
      artefact = FactoryGirl.build(:artefact, owning_app: 'publisher')

      assert_equal false, artefact.allow_specialist_sector_tag_changes?
    end
  end

  context '#allow_section_tag_changes?' do
    should 'be true for a non-publisher artefact' do
      artefact = FactoryGirl.build(:artefact, :non_publisher)

      assert artefact.allow_section_tag_changes?
    end

    should 'be false for a publisher artefact' do
      artefact = FactoryGirl.build(:artefact, owning_app: 'publisher')

      assert_equal false, artefact.allow_section_tag_changes?
    end
  end
end
