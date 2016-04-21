require_relative '../../test_helper'

class UpdateSpecialistSectorTagCallbackTest < ActiveSupport::TestCase
  setup do
    Panopticon.whitehall_admin_api.stubs(reindex_specialist_sector_editions: nil)
    Panopticon.publisher_api.stubs(reindex_topic_editions: nil)

    @tag = FactoryGirl.create(:draft_tag,
      tag_type: 'specialist_sector',
      tag_id: 'oil-and-gas/licensing',
      parent_id: 'oil-and-gas'
    )
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
