class DeletedPublicationListener
  class_attribute :client

  def listen
    Signal.trap('TERM') do
      client.close
      exit
    end
    marples = Marples::Client.new client, "deleted-publication-listener-#{Process.pid}", logger
    marples.when 'publisher', '*', 'deleted' do |publication|
      logger.info "Found publication #{publication}"
      begin
        logger.info("Processing artefact #{publication['panopticon_id']}")
        artefact = Artefact.find(publication['panopticon_id'])
        logger.info("Getting need ID from Panopticon")
        artefact.destroy
        logger.info("Artefact destroyed")
      rescue => e
        logger.error("Unable to process message #{publication}")
        logger.error [ e.message, e.backtrace ].flatten.join("\n")
      end
      logger.info "Finished processing message #{publication}"
    end
    logger.info "Listening for deleted objects in Publisher"
    marples.join
  end
  
  def logger
    @logger ||= begin
      logger = Logger.new STDOUT
      logger.level = Logger::DEBUG
      logger
    end
  end
  
  def client
    self.class.client ||= Stomp::Client.new(STOMP_CONFIGURATION)
  end
end
