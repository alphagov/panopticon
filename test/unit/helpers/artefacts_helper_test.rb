require_relative '../../test_helper'

class ArtefactsHelperTest < ActiveSupport::TestCase
  include ArtefactsHelper

  context "#manageable_formats" do
    should "exclude formats owned by Whitehall" do
      assert manageable_formats.exclude?('publication')
      assert manageable_formats.exclude?('speech')
    end

    should "exclude formats owned by Panopticon" do
      assert manageable_formats.exclude?('specialist_sector')
    end
  end

  context "#action_information_phrase" do
    setup do
      @artefact = FactoryGirl.create(:artefact)
    end

    context "when action is performed by user" do
      should "return user name and email" do
        user = FactoryGirl.create(:user)
        @artefact.actions.build(user: user, action_type: 'update')

        expected = "#{user} <#{user.email}> has updated this artefact."
        assert_equal expected, action_information_phrase(@artefact.actions.last)
      end
    end

    context "when action is performed by task" do
      context 'when performed by TaggingUpdater' do
        should "show updated tags phrase" do
          @artefact.actions.build(task_performed_by: 'TaggingUpdater', action_type: 'update')

          expected = "An external application has updated the tags for this artefact."
          assert_equal expected, action_information_phrase(@artefact.actions.last)
        end
      end

      %w(OrganisationSlugChanger move_content_to_new_topic).each do |task_name|
        context "when performed by #{task_name}" do
          should "show updated by a developer phrase" do
            @artefact.actions.build(task_performed_by: task_name, action_type: 'update')

            expected = "A developer has manually updated this artefact."
            assert_equal expected, action_information_phrase(@artefact.actions.last)
          end
        end
      end
    end

    context "when action is performed by unknown" do
      should "return unknown user or task" do
        expected = "An unknown user or task has created this artefact."
        assert_equal expected, action_information_phrase(@artefact.actions.last)
      end
    end

    context "when action is a DiffEnabledAction" do
      should "work as normal action" do
        action = @artefact.actions.build(task_performed_by: 'TaggingUpdater', action_type: 'update')
        diff_enabled_action = DiffEnabledAction.new(action, nil)

        expected = "An external application has updated the tags for this artefact."
        assert_equal expected, action_information_phrase(diff_enabled_action)
      end
    end
  end
end
