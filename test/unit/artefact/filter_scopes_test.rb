require_relative '../../test_helper'

class Artefact::FilterScopesTest < ActiveSupport::TestCase
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
      stub_artefact_callbacks

      @artefact_one = FactoryGirl.create(:artefact, slug: "child-benefit", state: "draft")
      @artefact_two = FactoryGirl.create(:artefact, slug: "become-magistrate", state: "draft")
      @artefact_three = FactoryGirl.create(:artefact, slug: "fishing-rod-licence", state: "archived")
    end

    should "return artefacts matching the provided state" do
      artefacts = Artefact.in_state("draft")

      assert_equal [@artefact_one.slug, @artefact_two.slug].sort, artefacts.map(&:slug).sort
    end
  end


  context "owned_by" do
    setup do
      @artefact_one = FactoryGirl.create(:artefact, slug: "starting-a-company", owning_app: "whitehall")
      @artefact_two = FactoryGirl.create(:artefact, slug: "business-overview", owning_app: "publisher")
      @artefact_three = FactoryGirl.create(:artefact, slug: "vat", owning_app: "calculators")
    end

    should "return artefacts matching the owned_by app" do
      artefacts = Artefact.owned_by("calculators")

      assert_equal [@artefact_three.slug], artefacts.map(&:slug)
    end
  end

  context "not_owned_by" do
    setup do
      @artefact_one = FactoryGirl.create(:artefact, slug: "starting-a-company", owning_app: "whitehall")
      @artefact_two = FactoryGirl.create(:artefact, slug: "business-overview", owning_app: "publisher")
      @artefact_three = FactoryGirl.create(:artefact, slug: "vat", owning_app: "calculators")
    end

    should "return artefacts not matching the excluded owning_app" do
      artefacts = Artefact.not_owned_by("calculators")

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
