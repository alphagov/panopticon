module TagRepository

  def self.load_all
    Tag.all
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