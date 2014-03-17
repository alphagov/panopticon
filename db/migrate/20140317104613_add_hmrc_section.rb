class AddHmrcSection < Mongoid::Migration
  TAG_ID = "tax/dealing-with-hmrc"

  def self.up
    Tag.create!(tag_id: TAG_ID, title: "Dealing with HMRC", tag_type: "section", parent_id: "tax")
  end

  def self.down
    Tag.by_tag_id(TAG_ID, "section").destroy
  end
end
