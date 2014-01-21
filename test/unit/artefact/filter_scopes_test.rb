require_relative '../../test_helper'

class Artefact::FilterScopesTest < ActiveSupport::TestCase

  context "with_tags" do
    setup do
      @tag_one = FactoryGirl.create(:tag, tag_type: "section", tag_id: "business")
      @tag_two = FactoryGirl.create(:tag, tag_type: "section", tag_id: "tax")
      @tag_three = FactoryGirl.create(:tag, tag_type: "section", tag_id: "driving")
      @tag_four = FactoryGirl.create(:tag, tag_type: "section", tag_id: "benefits")

      @artefact_one = FactoryGirl.create(:artefact, slug: "low-hanging-fruit", tag_ids: [@tag_one.tag_id])
      @artefact_two = FactoryGirl.create(:artefact, slug: "something-about-tax", tag_ids: [@tag_two.tag_id])
      @artefact_three = FactoryGirl.create(:artefact, slug: "tax-for-businesses", tag_ids: [@tag_one.tag_id, @tag_two.tag_id])
      @artefact_four = FactoryGirl.create(:artefact, slug: "keeping-bees", tag_ids: [])
    end

    should "return artefacts matching the provided tag" do
      artefacts = Artefact.with_tags([@tag_one.tag_id])

      assert_equal [@artefact_one.slug, @artefact_three.slug].sort, artefacts.map(&:slug).sort
    end

    should "return artefacts matching any of the provided tags" do
      artefacts = Artefact.with_tags([@tag_one.tag_id, @tag_two.tag_id, @tag_three.tag_id])

      assert_equal [@artefact_one.slug, @artefact_two.slug, @artefact_three.slug].sort, artefacts.map(&:slug).sort
    end

    should "return artefacts matching both tags when called multiple times" do
      artefacts = Artefact.with_tags([@tag_one.tag_id]).with_tags([@tag_two.tag_id])

      assert_equal [@artefact_three.slug], artefacts.map(&:slug)
    end

    should "return artefacts that have at least one tag from each collection when called multiple times" do
      artefacts = Artefact.with_tags([@tag_one.tag_id, @tag_three.tag_id])
                            .with_tags([@tag_two.tag_id, @tag_four.tag_id])

      assert_equal [@artefact_three.slug], artefacts.map(&:slug)
    end

    should "return no artefacts if the tag doesn't exist" do
      artefacts = Artefact.with_tags(["foo"])

      refute artefacts.any?
    end
  end

  context "with_parent_tag" do
    setup do
      @tag_one = FactoryGirl.create(:tag, tag_type: "section", tag_id: "business")
      @tag_two = FactoryGirl.create(:tag, tag_type: "section", tag_id: "business/employing-people", parent_id: "business")
      @tag_three = FactoryGirl.create(:tag, tag_type: "section", tag_id: "business/starting-up", parent_id: "business")
      @tag_four = FactoryGirl.create(:tag, tag_type: "section", tag_id: "driving")
      @tag_five = FactoryGirl.create(:tag, tag_type: "section", tag_id: "driving/tax-discs", parent_id: "driving")

      @artefact_one = FactoryGirl.create(:artefact, slug: "starting-a-company", tag_ids: [@tag_three.tag_id])
      @artefact_two = FactoryGirl.create(:artefact, slug: "business-overview", tag_ids: [@tag_one.tag_id])
      @artefact_three = FactoryGirl.create(:artefact, slug: "tax-disc", tag_ids: [@tag_five.tag_id])
      @artefact_four = FactoryGirl.create(:artefact, slug: "tax-discs-commercial-vehicles", tag_ids: [@tag_three.tag_id, @tag_five.tag_id])
    end

    should "return artefacts tagged with the tag or its children" do
      artefacts = Artefact.with_parent_tag(@tag_one.tag_type, @tag_one.tag_id)

      assert_equal [@artefact_one.slug, @artefact_two.slug, @artefact_four.slug].sort, artefacts.map(&:slug).sort
    end

    should "return artefacts tagged with at least one child of the tag when called multiple times" do
      artefacts = Artefact.with_parent_tag(@tag_one.tag_type, @tag_one.tag_id).with_parent_tag(@tag_four.tag_type, @tag_four.tag_id)

      assert_equal [@artefact_four.slug], artefacts.map(&:slug)
    end
  end

  context "of_kind" do
    setup do
      @artefact_one = FactoryGirl.create(:artefact, slug: "starting-a-company", kind: "answer")
      @artefact_two = FactoryGirl.create(:artefact, slug: "business-overview", kind: "answer")
      @artefact_three = FactoryGirl.create(:artefact, slug: "vat", kind: "guide")
    end

    should "return artefacts matching the provided kind" do
      artefacts = Artefact.of_kind("answer")

      assert_equal [@artefact_one.slug, @artefact_two.slug].sort, artefacts.map(&:slug).sort
    end
  end

  context "in_state" do
    setup do
      UpdateRouterObserver.any_instance.stubs(:after_save)
      UpdateSearchObserver.any_instance.stubs(:after_save)

      @artefact_one = FactoryGirl.create(:artefact, slug: "child-benefit", state: "draft")
      @artefact_two = FactoryGirl.create(:artefact, slug: "become-magistrate", state: "draft")
      @artefact_three = FactoryGirl.create(:artefact, slug: "fishing-rod-licence", state: "archived")
    end

    should "return artefacts matching the provided state" do
      artefacts = Artefact.in_state("draft")

      assert_equal [@artefact_one.slug, @artefact_two.slug].sort, artefacts.map(&:slug).sort
    end
  end

  context "matching_query" do
    setup do
      @artefact_one = FactoryGirl.create(:artefact, slug: "sherlock-holmes", name: "Sherlock Holmes", description: "Detective", kind: "transaction")
      @artefact_two = FactoryGirl.create(:artefact, slug: "john-watson", name: "John Watson", description: "Detective and assistant", kind: "guide")
      @artefact_three = FactoryGirl.create(:artefact, slug: "professor-moriarty", name: "Prof. Moriarty", description: "Criminal", kind: "answer")
    end

    should "return artefacts matching the slug" do
      artefacts = Artefact.matching_query("sherlock-holmes")

      assert_equal [@artefact_one.slug], artefacts.map(&:slug)
    end

    should "return artefacts matching the name" do
      artefacts = Artefact.matching_query("John Watson")

      assert_equal [@artefact_two.slug], artefacts.map(&:slug)
    end

    should "return artefacts matching the description" do
      artefacts = Artefact.matching_query("Detective")

      assert_equal [@artefact_one.slug, @artefact_two.slug].sort, artefacts.map(&:slug).sort
    end

    should "return artefacts matching the kind" do
      artefacts = Artefact.matching_query("answer")

      assert_equal [@artefact_three.slug], artefacts.map(&:slug)
    end
  end

end
