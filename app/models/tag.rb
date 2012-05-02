class Tag
  include Mongoid::Document
  field :tag_id, :type => String
  field :title, :type => String
  field :tag_type, :type => String #TODO: list of accepted types?

  index :tag_id, :unique => true

  validates_presence_of :tag_id, :title, :tag_type

  def as_json(options={})
    {
      :id => self.tag_id,
      :title => self.title,
      :type => self.tag_type
    }
  end
end
