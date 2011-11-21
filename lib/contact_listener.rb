class ContactListener
  def process(message)
    logger.info "Received message #{message}"

    begin
      logger.info "Processing contact #{message['id']}"
      yield Contact.find_or_initialize_by_contactotron_id(message['id'])
    rescue => e
      logger.error "Unable to process message #{message}"
      logger.error [e.message, e.backtrace].flatten.join("\n")
    end

    logger.info "Finished processing message #{message}"
  end

  def listen
    Signal.trap 'TERM' do
      client.close
      exit
    end

    marples = Messenger.instance.client

    marples.when 'contactotron', '*', 'created' do |message|
      process message do |contact|
        logger.info "Creating contact #{message['id']}"
        contact.update_from_contactotron
      end
    end

    marples.when 'contactotron', '*', 'updated' do |message|
      process message do |contact|
        logger.info "Updating contact #{message['id']}"
        contact.update_from_contactotron
      end
    end

    logger.info 'Listening for created and updated contacts in Contact-o-tron'
    marples.join
  end

  def logger
    @logger ||= Logger.new(STDOUT).tap { |logger| logger.level = Logger::DEBUG }
  end
end
