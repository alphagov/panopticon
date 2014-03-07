module TagsHelper
  def options_for_tags_of_type(tag_type)
    Tag.where(:tag_type => tag_type).order_by(:title, :asc).map {|t| [t.title, t.tag_id]}
  end

  def grouped_options_for_tags_of_type(tag_type)
    parents = Tag.where(:tag_type => tag_type, :parent_id => nil).order(:title).all
    tags = Tag.where(:tag_type => tag_type).order([:parent_id, :asc], [:title, :asc])

    tags.group_by {|tag|
      if tag.has_parent?
        parent = parents.select {|p| tag.parent_id == p.tag_id }.first
        parent.title if parent
      else
        tag.title
      end
    }.map {|parent, tags|
      [parent, tags.map {|t|
        # don't repeat the parent title if it's the same
        # (eg. the parent category entry)
        formatted_tag_title = (t.title == parent) ? t.title : "#{parent}: #{t.title}"

        [formatted_tag_title, t.tag_id]
      }]
    }
  end
end
