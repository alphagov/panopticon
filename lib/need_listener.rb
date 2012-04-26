require "abstract_listener"

class NeedListener < AbstractListener

  listen 'need-o-tron', 'needs', 'updated' do |need, logger|
    logger.info "Found need #{need}"
    logger.info "Processing need `#{need['title']}`"

    artefact = Artefact.find_by_need_id(need['id'])
    logger.info "Found artefact `#{artefact.name}` in Panopticon"

    require 'gds_api/needotron'
    api = GdsApi::Needotron.new(Plek.current.environment)
    need_data = api.need_by_id(need['id'])
    logger.info "Getting need information from `#{need['id']}`"

    artefact.department = need_data.writing_team.name rescue nil
    artefact.fact_checkers = need_data.fact_checkers.collect{ |e| e.fact_checker.email }.join(', ')
    artefact.save!
    logger.info "----> Saved `#{artefact.name}` with department `#{artefact.department}` and fact checkers `#{artefact.fact_checkers}`"
  end
end
