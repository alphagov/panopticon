require 'test_helper'
require 'govuk_message_queue_consumer/test_helpers'

class TaggingUpdaterTest < ActiveSupport::TestCase
  def test_message_is_acked
    message = GovukMessageQueueConsumer::MockMessage.new

    TaggingUpdater.new.process(message)

    assert message.acked?
  end
end
