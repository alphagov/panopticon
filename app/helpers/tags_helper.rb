module TagsHelper
  def options_for_tags_of_type(tag_type)
    Tag.where(:tag_type => tag_type).order(:title).map {|t| [t.title, t.tag_id]}
  end

  def grouped_options_for_tags_of_type(tag_type)
    parents = Tag.where(:tag_type => tag_type, :parent_id => nil).order(:title).all
    tags = Tag.where(:tag_type => tag_type, :parent_id.ne => nil).order(:title)

    tags.group_by {|tag|
      parent = parents.select {|p| tag.parent_id == p.tag_id }.first
      parent.title if parent
    }.map {|parent, tags|
      [parent, tags.map {|t| ["#{parent}: #{t.title}", t.tag_id] }]
    }
  end
end
