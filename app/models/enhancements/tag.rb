require 'tag'

class Tag
  class TagNotFound < StandardError; end

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
end
