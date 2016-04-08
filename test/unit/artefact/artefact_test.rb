require_relative '../../test_helper'

class Artefact::ArtefactTest < ActiveSupport::TestCase

  context "tagging_migrated?" do

    context 'standard set of untaggable apps (publisher, smartanswers and testapp)' do

      should "return false for artifacts not owned by publisher, smartanswers or testapp" do
        artefact = FactoryGirl.create(:artefact, slug: "low-hanging-fruit", owning_app: 'whitehall')
        assert_equal false, artefact.tagging_migrated?
      end

      should 'return true for artefacts owned by publisher, smartanswers or testapp' do
        artefact = FactoryGirl.create(:artefact, slug: "low-hanging-fruit", owning_app: 'testapp')
        assert_equal true, artefact.tagging_migrated?
      end

      should 'return false if new record and owning app is nil' do
        artefact = Artefact.new
        assert_equal false, artefact.tagging_migrated?
      end

      should 'return true if new record and owning app is migrated' do
        artefact = Artefact.new(owning_app: 'testapp')
        assert_equal true, artefact.tagging_migrated?
      end

      should 'return false if new record and owning app not migrated' do
        artefact = Artefact.new(owning_app: 'whitehall')
        assert_equal false, artefact.tagging_migrated?
      end
    end
  end
end
