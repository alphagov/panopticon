# TaggingMigrator
#
# We are migrating the taggings from panopticon/content-api to publishing-api.
# This class takes the taggings for a certain app and sends it to the
# publishing-api so that it contains the current taggings. This functionality
# will be removed after the migration.

require 'gds_api/publishing_api_v2'

class TaggingMigrator
  attr_reader :app_name
  attr_reader :link_types
  attr_reader :scope

  LINK_TYPES = [
    :mainstream_browse_pages,
    :topics,
    :organisations,
    :parent,
  ]

  def initialize(app_name, link_types: LINK_TYPES, scope: Artefact)
    @app_name = app_name
    @link_types = link_types
    @scope = scope
  end

  def migrate!
    artefacts_owned_by_app.each do |artefact|
      unless artefact.content_id
        puts "Skipping #{artefact.slug}: no content id"
        next
      end

      puts "Migrating #{artefact.slug}"
      migrate_tags_for_artefact(artefact)
    end
  end

private

  def migrate_tags_for_artefact(artefact)
    puts link_payload(artefact)
    publishing_api.patch_links(
      artefact.content_id,
      links: link_payload(artefact),
      bulk_publishing: true
    )
  end

  def artefacts_owned_by_app
    scope.where(owning_app: @app_name)
  end

  def link_payload(artefact)
    payload = {
      mainstream_browse_pages: [],
      topics: [],
      organisations: [],
    }

    unless @app_name == 'travel-advice-publisher'
      if artefact.primary_section
        payload[:parent] = [artefact.primary_section.content_id]
      end
    end

    artefact.tags.each do |tag|
      if tag.tag_type == 'section'
        payload[:mainstream_browse_pages] << tag.content_id
      end

      if tag.tag_type == 'specialist_sector'
        payload[:topics] << tag.content_id
      end

      if tag.tag_type == 'organisation'
        payload[:organisations] << tag.content_id
      end
    end

    payload.slice(*link_types)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end
end
