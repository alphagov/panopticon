require 'gds_api/organisations'

class OrganisationImporter
  TAG_TYPE = "organisation"

  def run
    logger.info "Fetching all organisations from the Organisation API"
    organisations = organisations_api.organisations.with_subsequent_pages.to_a
    logger.info "Loaded #{organisations.size} organisations"

    organisations.each do |organisation|
      create_or_update_organisation(organisation)
    end

    logger.info "Import complete"
  end

  private

  def create_or_update_organisation(organisation)
    tag_id = organisation.details.slug
    existing_tag = Tag.where(tag_type: TAG_TYPE, tag_id: tag_id).first

    if existing_tag.present?
      if existing_tag.title != organisation.title
        if existing_tag.update_attributes(title: organisation.title)
          logger.info "Found existing tag: #{tag_id}; updated title to '#{existing_tag.title}'"
        else
          log_error_and_notify_airbrake(organisation,
                                        "Found existing tag: #{tag_id}; could not update title: #{existing_tag.errors.full_messages}")
        end
      else
        logger.info "Found existing tag: #{tag_id}"
      end
    else
      new_tag = Tag.new(tag_type: TAG_TYPE,
                        tag_id: tag_id,
                        title: organisation.title)

      if new_tag.save
        logger.info "Created organisation tag: #{tag_id}"
      else
        log_error_and_notify_airbrake(organisation,
                                      "Could not create organisation tag: #{tag_id} - #{new_tag.errors.full_messages}")
      end
    end
  end

  def logger
    @logger ||= build_logger
  end

  def build_logger
    output = case Rails.env
             when "development" then STDOUT
             when "test" then "/dev/null"
             when "production" then Rails.root.join("log", "organisation_import.json.log")
             end

    Logger.new(output).tap {|logger|
      logger.formatter = json_log_formatter if Rails.env.production?
    }
  end

  def json_log_formatter
    proc {|severity, datetime, progname, message|
      {
        "@message" => message,
        "@tags" => ["cron", "rake"],
        "@timestamp" => datetime.iso8601
      }.to_json + "\n"
    }
  end

  def organisations_api
    @api_client ||= GdsApi::Organisations.new(Plek.current.find('whitehall-admin'))
  end

  def log_error_and_notify_airbrake(organisation, message)
    logger.warn message

    Airbrake.notify_or_ignore(
      StandardError.new(message),
      :parameters => { :organisation => organisation }
    )
  end
end
