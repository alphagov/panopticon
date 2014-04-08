require_relative '../test_helper'
require 'gds_api/need_api'

class ArtefactTest < ActiveSupport::TestCase

  context "need_owning_service" do
    should "return needotron when need_id =< 5000" do
      artefact = FactoryGirl.create(:artefact, need_id: "99999")

      assert_equal "needotron", artefact.need_owning_service
    end

    should "return maslow when need_id >= 100000" do
      artefact = FactoryGirl.create(:artefact, need_id: "100000")

      assert_equal "maslow", artefact.need_owning_service
    end

    should "return nil if need_id is nil" do
      artefact = FactoryGirl.create(:artefact, need_id: nil)

      assert_nil artefact.need_owning_service
    end

    should "return nil if need_id is empty" do
      artefact = FactoryGirl.create(:artefact, need_id: "")

      assert_nil artefact.need_owning_service
    end

    should "return nil if need_id is non-numeric" do
      artefact = FactoryGirl.create(:artefact, need_id: "B5678")

      assert_nil artefact.need_owning_service
    end
  end

  context "need_id_editable?" do
    should "return true for a new record" do
      artefact = Artefact.new

      assert artefact.need_id_editable?
    end

    should "return true when need_id is nil" do
      artefact = FactoryGirl.create(:artefact, need_id: nil)

      assert artefact.need_id_editable?
    end

    should "return true when need_id is blank" do
      artefact = FactoryGirl.create(:artefact, need_id: "")

      assert artefact.need_id_editable?
    end

    should "return true when need_id is not a number" do
      artefact = FactoryGirl.create(:artefact, need_id: "B5253")

      assert artefact.need_id_editable?
    end

    should "return false when need_id >= 100000" do
      artefact = FactoryGirl.create(:artefact, need_id: "100000")

      refute artefact.need_id_editable?
    end

    should "return true when need_id < 100000" do
      artefact = FactoryGirl.create(:artefact, need_id: "99999")

      assert artefact.need_id_editable?
    end
  end

  context "need_id_numeric?" do
    should "be true for a number" do
      artefact = FactoryGirl.build(:artefact, need_id: "12345")

      assert artefact.need_id_numeric?
    end

    should "not be true when not a number" do
      artefact = FactoryGirl.build(:artefact, need_id: "NOT A NUMBER, HONEST")

      refute artefact.need_id_numeric?
    end
  end

  context "need" do
    context "given a maslow need id" do
      setup do
        @need = OpenStruct.new(id: "100123", role: "user", goal: "pay my car tax", benefit: "i can drive my car")
      end

      should "fetch the need from the Need API" do
        artefact = FactoryGirl.build(:artefact, need_id: "100123")
        GdsApi::NeedApi.any_instance.stubs(:need).with("100123").returns(@need)

        assert artefact.need.present?

        assert_equal "100123", artefact.need.id
        assert_equal "user", artefact.need.role
        assert_equal "pay my car tax", artefact.need.goal
        assert_equal "i can drive my car", artefact.need.benefit
      end

      should "be nil if there are any api errors" do
        artefact = FactoryGirl.build(:artefact, need_id: "100123")
        GdsApi::NeedApi.any_instance.stubs(:need)
                                      .with("100123")
                                      .raises(GdsApi::HTTPErrorResponse.new(500))

        assert_nil artefact.need
      end
    end

    should "be nil if there is no need id" do
      artefact = FactoryGirl.build(:artefact, need_id: nil)

      assert_nil artefact.need
    end

    should "be nil if need is not a maslow need" do
      artefact_one = FactoryGirl.build(:artefact, need_id: "B5256")
      artefact_two = FactoryGirl.build(:artefact, need_id: "2345")

      assert_nil artefact_one.need
      assert_nil artefact_two.need
    end
  end

end
