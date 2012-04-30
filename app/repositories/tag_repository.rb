module TagRepository

  def self.load_all
    Tag.all
  end

  def self.load(id)
    Tag.where(:tag_id => id).first
  end
end