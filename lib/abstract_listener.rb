class AbstractListener

  def initialize(messenger = Messenger.instance.client, logger = Rails.logger)
    @messenger = messenger
    @logger = logger
  end
  attr_reader :messenger, :logger

  def listen
    Signal.trap('TERM') do
      client.close
      exit
    end

    self.class.listeners.each do |messages, handler|
      messenger.when *messages do |message|
        logger.info "Received message #{message}"
        begin
          handler.call(message, logger)
        rescue => e
          logger.error "Unable to process message #{message}"
          logger.error [e.message, e.backtrace].flatten.join("\n")
        end
        logger.info "Finished processing message #{message}"
      end
    end

    messenger.join
  end

  def self.listen(*messages, &handler)
    listeners << [messages, handler]
  end

  def self.listeners
    @listeners ||= []
  end
end
