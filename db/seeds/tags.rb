def create_or_update_tag(options)
  tag_id = options.delete(:tag_id)
  tag = Tag.where(:tag_id => tag_id).first || Tag.new(:tag_id => tag_id)
  tag.update_attributes(options)
end

create_or_update_tag(
    tag_type: "section",
    title: "Global",
    tag_id: "global",
    description: "Generic content that should be pulled onto the global site")

create_or_update_tag(
    tag_type: "section",
    title: "London",
    tag_id: "london",
    description: "Generic content that should be pulled onto the London site")

create_or_update_tag(
    tag_type: "section",
    title: "Learning",
    tag_id: "learning",
    description: "Generic content that should be pulled onto the learning site")

