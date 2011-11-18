class NeedListener
                  
  def initialize
    @marples = Messenger.instance.client  
  end
  
  def listen
    Signal.trap('TERM') do
      client.close
      exit
    end
    
    listen_on_updated
    @marples.join
  end                                  
  
  def listen_on_updated
    @marples.when 'need-o-tron', '*', 'updated' do |need|
      logger.info "Found need #{need}"

      begin
        logger.info "Processing need `#{need['title']}`"
                                                                     
        need_data = JSON.parse open( Plek.current.find('needotron') + "/needs/#{need['id']}.json" ).read
        artefact = Artefact.find_by_need_id(need['id'])
        logger.info "Found artefact `#{artefact.name}` in Panopticon"
        
        artefact.department = need_data['need']['writing_team']['name'] rescue nil                      
        artefact.fact_checkers = need_data['need']['fact_checkers'].collect{ |e| e['fact_checker']['email'] }.join(', ')                                                       
        artefact.save!
        logger.info "\t--> Saved `#{artefact.name}` with department `#{artefact.department}` and fact checkers `#{artefact.fact_checkers}`"                          
      rescue => e
        logger.error "Unable to process message #{need}"
        logger.error [e.message, e.backtrace].flatten.join("\n")
      end

      logger.info "Finished processing message #{need}"
    end

    logger.info 'Listening for updated objects in Needotron'
  end

  def logger
    @logger ||= Logger.new(STDOUT).tap { |logger| logger.level = Logger::DEBUG }
  end
end
