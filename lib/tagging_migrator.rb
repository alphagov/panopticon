# TaggingMigrator
#
# We are migrating the taggings from panopticon/content-api to publishing-api.
# This class takes the taggings for a certain app and sends it to the
# publishing-api so that it contains the current taggings. This functionality
# will be removed after the migration.

require 'gds_api/publishing_api_v2'

class TaggingMigrator
  def initialize(app_name)
    @app_name = app_name
  end

  def migrate!
    artefacts_owned_by_app.each do |artefact|
      next unless artefact.content_id
      migrate_tags_for_artefact(artefact)
    end
  end

private

  def migrate_tags_for_artefact(artefact)
    link_payload = {
      mainstream_browse_pages: [],
      topics: [],
      organisations: [],
    }

    if artefact.primary_section
      link_payload[:parent] = [artefact.primary_section.content_id]
    end

    artefact.tags.each do |tag|
      if tag.tag_type == 'section'
        link_payload[:mainstream_browse_pages] << tag.content_id
      end

      if tag.tag_type == 'specialist_sector'
        link_payload[:topics] << tag.content_id
      end

      if tag.tag_type == 'organisation'
        link_payload[:organisations] << tag.content_id
      end
    end

    publishing_api.put_links(
      artefact.content_id,
      links: link_payload
    )
  end

  def artefacts_owned_by_app
    Artefact.where(owning_app: @app_name)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end
end
