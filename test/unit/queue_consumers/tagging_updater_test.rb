require 'test_helper'
require 'govuk_message_queue_consumer/test_helpers'

class TaggingUpdaterTest < ActiveSupport::TestCase
  def test_artefact_is_updated_with_tags
    create(:live_tag, tag_id: 'my-tag', tag_type: 'section', content_id: 'MY-CONTENT-ID')
    create(:live_tag, tag_id: 'existing-tag', tag_type: 'section', content_id: 'A-CONTENT-ID')
    artefact = create(:artefact,
      slug: 'a-tagged-item',
      sections: ["existing-tag"],
    )
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "smartanswers",
      "base_path" => "/a-tagged-item",
      "links" => { "mainstream_browse_pages" => ["MY-CONTENT-ID"] }
    })

    TaggingUpdater.new.process(message)

    artefact.reload
    assert_equal ["my-tag"], artefact.tags.map(&:tag_id)
    assert message.acked?
  end

  def test_only_migrated_applications
    create(:live_tag, tag_id: 'existing-tag', tag_type: 'section', content_id: 'A-CONTENT-ID')
    artefact = create(:artefact,
      slug: 'a-tagged-item',
      sections: ["existing-tag"],
    )
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "not-smartanswers",
      "base_path" => "/a-tagged-item",
      "links" => { "mainstream_browse_pages" => ["MY-CONTENT-ID"] }
    })

    TaggingUpdater.new.process(message)

    artefact.reload
    assert_equal ["existing-tag"], artefact.tags.map(&:tag_id)
    assert message.acked?
  end

  def test_when_no_artefact_found
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "smartanswers",
      "base_path" => "/some-item-that-does-not-exist",
      "links" => { "mainstream_browse_pages" => ["MY-CONTENT-ID"] }
    })

    TaggingUpdater.new.process(message)

    assert message.acked?
  end

  def test_when_links_are_missing
    artefact = create(:artefact, slug: 'an-item')
    message = GovukMessageQueueConsumer::MockMessage.new({
      "publishing_app" => "smartanswers",
      "base_path" => "/an-item",
    })

    TaggingUpdater.new.process(message)

    assert message.acked?
  end
end
