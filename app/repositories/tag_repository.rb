module TagRepository

  # Load all tags. If tag_type parameter is given, load all tags of that type.
  def self.load_all(options={})
    tag_type = options[:tag_type]
    if tag_type.nil?
      Tag.all
    else
      Tag.where(:tag_type => tag_type)
    end
  end

  def self.load(id)
    Tag.where(:tag_id => id).first
  end

  def self.put(tag)
    t = Tag.where(:tag_id => tag[:tag_id]).first
    unless t
      Tag.create! tag
    else
      t.update_attributes! tag
    end
  end
end