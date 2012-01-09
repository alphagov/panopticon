class PublicationListener
  def listen
    Signal.trap('TERM') do
      client.close
      exit
    end

    marples = Messenger.instance.client

    marples.when 'publisher', '*', 'updated' do |publication|
      logger.info "Found publication #{publication}"

      begin
        logger.info "Processing artefact #{publication['panopticon_id']}"
        logger.info "Publication #{publication['_id']}"

        artefact = Artefact.find(publication['panopticon_id'])
        artefact.update_attribute :publication_id, publication['_id']

        logger.info 'Artefact saved'
      rescue => e
        logger.error "Unable to process message #{publication}"
        logger.error [e.message, e.backtrace].flatten.join("\n")
      end

      logger.info "Finished processing message #{publication}"
    end

    logger.info 'Listening for updated objects in Publisher'
    marples.join
  end

  def logger
    @logger ||= Rails.logger
  end
end
