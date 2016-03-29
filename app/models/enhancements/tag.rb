require 'tag'

class Tag
  class TagNotFound < StandardError; end

  # When saving a specialist sector tag we want to update the title of the
  # associated artefact
  after_update :update_specialist_sector_tag

  def to_param
    "#{tag_type}/#{tag_id}"
  end

  def self.find_by_param(param)
    # param can be a BSON ID
    tag = Tag.where(_id: param).first
    return tag if tag.present?

    # param can be of format /:tag_type/:tag_id
    tag_type, tag_id = param.match(/([^\/]+)\/([^\.]+)/) {|matches|
      [ matches[1], matches[2] ]
    }
    tag = Tag.by_tag_id(tag_id, type: tag_type, draft: true)

    unless tag.present?
      raise TagNotFound, param
    end

    tag
  end

  def update_specialist_sector_tag
    if tag_type == 'specialist_sector'
      reindex_tagged_documents if state_changed? && live?
    end
  end

private

  def reindex_tagged_documents
    Panopticon.whitehall_admin_api.reindex_specialist_sector_editions(tag_id)
    Panopticon.publisher_api.reindex_topic_editions(tag_id)
  end
end
