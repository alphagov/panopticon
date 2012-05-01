require "abstract_listener"

class DeletedPublicationListener < AbstractListener

  listen 'publisher', '*', 'destroyed' do |publication, logger|
    logger.info "Found publication #{publication}"
    logger.info "Processing artefact #{publication['panopticon_id']}"
    artefact = Artefact.find(publication['panopticon_id'])
    logger.info 'Getting need ID from Panopticon'
    artefact.destroy
    logger.info 'Artefact destroyed'
  end
end
