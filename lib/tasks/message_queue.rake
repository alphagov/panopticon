namespace :message_queue do
  desc "Run worker to consume messages from RabbitMQ"
  task consumer: :environment do
    require "statsd"

    statsd_client = Statsd.new
    statsd_client.namespace = "govuk.app.panopticon"

    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "panopticon",
      processor: TaggingUpdater.new,
      statsd_client: statsd_client,
    ).run
  end
end
