require 'test_helper'
require 'govuk_message_queue_consumer/test_helpers'

class TaggingUpdaterTest < ActiveSupport::TestCase
  def test_artefact_is_updated_with_tags
    create(:live_tag, tag_id: 'new-tag', tag_type: 'section', content_id: 'NEW-TAG-CONTENT-ID')
    create(:live_tag, tag_id: 'parent-tag', tag_type: 'section', content_id: 'PARENT-TAG-CONTENT-ID')
    create(:live_tag, tag_id: 'existing-tag', tag_type: 'section', content_id: 'EXISTING-TAG-CONTENT-ID')
    artefact = create(:artefact,
      slug: 'an-item-with-links',
      sections: ["existing-tag"],
    )
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "a-publishing-app",
      "base_path" => "/an-item-with-links",
      "links" => {
        "mainstream_browse_pages" => ["NEW-TAG-CONTENT-ID"],
        "parent" => ["PARENT-TAG-CONTENT-ID"],
      }
    })

    TaggingUpdater.new.process(message)

    artefact.reload
    assert_equal ["parent-tag", "new-tag"], artefact.tags.map(&:tag_id)
    assert message.acked?
  end

  def test_links_are_cleared
    create(:live_tag, tag_id: 'existing-tag', tag_type: 'section', content_id: 'EXISTING-TAG-CONTENT-ID')
    artefact = create(:artefact,
      slug: 'an-item-with-links',
      sections: ["existing-tag"],
    )
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "a-publishing-app",
      "base_path" => "/an-item-with-links",
      "links" => {}
    })

    TaggingUpdater.new.process(message)

    artefact.reload
    assert_equal [], artefact.tags.map(&:tag_id)
    assert message.acked?
  end

  def test_when_no_artefact_found
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "a-publishing-app",
      "base_path" => "/some-item-that-does-not-exist",
      "links" => { "mainstream_browse_pages" => ["NEW-TAG-CONTENT-ID"] }
    })

    TaggingUpdater.new.process(message)

    assert message.acked?
  end

  def test_when_links_are_missing_in_the_message
    create(:live_tag, tag_id: 'existing-tag', tag_type: 'section', content_id: 'EXISTING-TAG-CONTENT-ID')
    artefact = create(:artefact,
      slug: 'an-item-with-links',
      sections: ["existing-tag"],
    )
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "a-publishing-app",
      "base_path" => "/an-item-with-links",
    })

    assert_equal ["existing-tag"], artefact.tags.map(&:tag_id)

    TaggingUpdater.new.process(message)

    artefact.reload
    assert_equal ["existing-tag"], artefact.tags.map(&:tag_id)
    assert message.acked?
  end

  def test_missing_base_path_messages_are_acked_and_skipped
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "a-publishing-app",
      "base_path" => nil,
    })

    assert TaggingUpdater.new.process(message)
  end
end
