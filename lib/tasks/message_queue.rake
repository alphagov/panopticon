namespace :message_queue do
  desc "Run worker to consume messages from RabbitMQ"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "panopticon",
      processor: TaggingUpdater.new
    ).run
  end
end
