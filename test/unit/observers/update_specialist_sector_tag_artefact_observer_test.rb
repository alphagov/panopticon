require_relative '../../test_helper'

class UpdateSpecialistSectorTagArtefactObserverTest < ActiveSupport::TestCase
  setup do
    stub_all_router_api_requests
    stub_all_rummager_requests
    Panopticon.whitehall_admin_api.stubs(reindex_specialist_sector_editions: nil)
    Panopticon.publisher_api.stubs(reindex_topic_editions: nil)

    @tag = FactoryGirl.create(:draft_tag,
      tag_type: 'specialist_sector',
      tag_id: 'oil-and-gas/licensing',
      parent_id: 'oil-and-gas'
    )
  end

  context 'when an artefact exists for the tag' do
    setup do
      @artefact = FactoryGirl.create(:artefact,
        kind: 'specialist_sector',
        slug: 'oil-and-gas/licensing'
      )
    end

    should 'update the artefact name' do
      @tag.update_attributes(title: 'A brand new title')
      assert_equal 'A brand new title', @artefact.reload.name
    end

    should 'update the artefact state' do
      @tag.publish!
      assert_equal 'live', @artefact.reload.state
    end

    should 'trigger reindex of tagged documents on publish' do
      Panopticon.whitehall_admin_api.expects(:reindex_specialist_sector_editions).with('oil-and-gas/licensing').once
      Panopticon.publisher_api.expects(:reindex_topic_editions).with('oil-and-gas/licensing').once

      @tag.publish!
    end

    should 'not trigger reindex of tagged documents on non-publish saves' do
      Panopticon.whitehall_admin_api.expects(:reindex_specialist_sector_editions).never
      Panopticon.publisher_api.expects(:reindex_topic_editions).never

      @tag.update_attributes(title: 'A brand new title')
    end
  end

  context 'when an artefact does not exist for the tag' do
    should 'do nothing' do
      assert_difference 'Artefact.count', 0 do
        @tag.update_attributes(title: 'A brand new title')
      end
    end
  end
end
