require "test_helper"

class MessageQueueConsumerRakeTest < ActiveSupport::TestCase
  # minitest doesn't provide this by default
  def refute_raises(exception)
    yield
  rescue Exception => err
    flunk "Expected no failures but #{mu_pp(err).chomp} was raised."
  end

  context "when consuming messages from RabbitMQ" do
    setup do
      # The consumer needs this values when initialized
      ENV["RABBITMQ_HOSTS"] = "server-one,server-two"
      ENV["RABBITMQ_VHOST"] = "/"
      ENV["RABBITMQ_USER"] = "my_user"
      ENV["RABBITMQ_PASSWORD"] = "my_pass"

      @consumer = GovukMessageQueueConsumer::Consumer
    end

    should "use GovukMessageQueueConsumer::Consumer API correctly" do
      assert_raises(ArgumentError) { @consumer.new }
      assert_raises(ArgumentError) { @consumer.new(queue_name: "panopticon") }
      assert_raises(ArgumentError) { @consumer.new(bad_name: "panopticon") }

      refute_raises(ArgumentError) do
        @consumer.new(
          queue_name: "panopticon",
          processor: Object.new,
        )
      end
    end

    should "call GovukMessageQueueConsumer::Consumer" do
      tagging_updater = mock('TaggingUpdater')
      TaggingUpdater.expects(:new).returns(tagging_updater)

      statsd_client = Statsd.new
      Statsd.expects(:new).returns(statsd_client)

      @consumer.expects(:run).returns(true)

      GovukMessageQueueConsumer::Consumer.expects(:new)
        .with(
          queue_name: "panopticon",
          processor: tagging_updater,
          statsd_client: statsd_client,
        ).returns(@consumer)

      Rake::Task["message_queue:consumer"].invoke
    end
  end
end

