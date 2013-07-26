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
     
create_or_update_tag(
    tag_type: "section",
    title: "People",
    tag_id: "people",
    description: "Generic content that should be pulled onto the people site")

create_or_update_tag(
    tag_type: "section",
    title: "Tech Team",
    tag_id: "people/tech-team",
    parent_id: "people",
    description: "People in the tech team")

create_or_update_tag(
    tag_type: "section",
    title: "Commercial Team",
    tag_id: "people/commercial-team",
    parent_id: "people",
    description: "People in the commercial team")
    
create_or_update_tag(
    tag_type: "section",
    title: "Executive Team",
    tag_id: "people/executive-team",
    parent_id: "people",
    description: "People in the executive team")

create_or_update_tag(
    tag_type: "section",
    title: "Board",
    tag_id: "people/board",
    parent_id: "people",
    description: "People on the board")
    
create_or_update_tag(
    tag_type: "section",
    title: "Operations Team",
    tag_id: "people/operations-team",
    parent_id: "people",
    description: "People in the operations team")
    
create_or_update_tag(
    tag_type: "section",
    title: "News",
    tag_id: "news",
    description: "News")