# TaggingUpdater
#
# To allow us to migrate to the new tagging infrastructure, we need to have
# taggings be synced between panopticon and publishing-api. This class makes
# sure that if an app sends `links` to the publishing-api, panopticon/contentapi
# is also updated.
class TaggingUpdater
  def process(message)
    content_item = message.payload
    process_content_item(content_item)
    message.ack
  end

private
  def process_content_item(content_item)
    return unless content_item['links']

    # Panopticon pre-dates content items without base paths.
    # We can ignore this content.
    base_path = content_item['base_path']
    return unless base_path

    artefact = find_artefact_by_base_path(base_path)

    return unless artefact
    update_artefact_with_content_item(content_item, artefact)
  end

  def find_artefact_by_base_path(base_path)
    slug_without_leading_slash = base_path.sub(/\A\//, '')
    Artefact.find_by_slug(slug_without_leading_slash)
  end

  # Panopticon still uses deprecated names for the tags.
  TAG_MAPPING = {
    "mainstream_browse_pages" => "section",
    "organisations" => "organisation",
    "topics" => "specialist_sector",
  }

  def update_artefact_with_content_item(content_item, artefact)
    TAG_MAPPING.each do |publishing_api_tag_name, panopticon_tag_name|
      if content_item['links'][publishing_api_tag_name]
        new_tags = Tag.where(:content_id.in => content_item['links'][publishing_api_tag_name])
      else
        new_tags = []
      end

      artefact.set_tags_of_type(panopticon_tag_name, new_tags.map(&:tag_id))
    end

    unless content_item.fetch('publishing_app') == 'travel-advice-publisher'
      if content_item['links']['parent']
        parent = Tag.where(:content_id.in => content_item['links']['parent']).first

        if parent && parent.tag_type == 'section'
          artefact.set_primary_tag_of_type('section', parent.tag_id)
        end
      end
    end

    artefact.save_as_task!('TaggingUpdater')
  end
end
