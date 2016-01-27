module Importers
  class MainstreamOrganisationTagImporter
    def initialize(need_api)
      @need_api = need_api
    end

    def run
      logger.info "Starting #{self.class.name}"

      artefacts_with_needs.each do |artefact|
        begin
          import_organisations_for_artefact(artefact)
        rescue GdsApi::TimedOutException
          logger.info "    Timed out, retrying"
          redo
        end
      end

      logger.info "Import completed"
    end

  private

    def import_organisations_for_artefact(artefact)
      logger.info "  #{artefact.slug}:"
      logger.info "    -> need IDs: #{artefact.need_ids.join(', ')}"

      needs = maslow_need_ids(artefact).map {|need_id|
        @need_api.need(need_id)
      }.compact
      logger.info "    -> Maslow needs found: #{needs.size}"

      organisation_ids_to_add = needs.map {|need|
        need['organisation_ids']
      }.flatten

      organisation_ids = (artefact.organisation_ids(draft: true) + organisation_ids_to_add).uniq

      artefact.organisation_ids = organisation_ids
      artefact.save

      logger.info "    -> organisation_ids = #{organisation_ids}"
    end

    def mainstream_owning_apps
      [
        'calculators',
        'calendars',
        'publisher',
        'smartanswers',
        'travel-advice-publisher',
      ]
    end

    def artefacts_with_needs
      Artefact.where("need_ids.0".to_sym.exists => true,
                     :owning_app.in => mainstream_owning_apps,
                     :state.ne => 'archived')
    end

    def maslow_need_ids(artefact)
      artefact.need_ids.select {|need_id|
        need_id =~ /\A\d{6}\Z/
      }
    end

    def logger
      # Don't output in the test environment, to avoid test output getting noisy
      output = Rails.env.test? ? "/dev/null" : STDOUT
      @logger ||= Logger.new(output)
    end
  end
end
