require_relative '../test_helper'

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

end
