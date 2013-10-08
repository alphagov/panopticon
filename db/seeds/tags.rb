def create_or_update_tag(options)
  tag_id = options.delete(:tag_id)
  tag = Tag.where(:tag_id => tag_id).first || Tag.new(:tag_id => tag_id)
  tag.update_attributes(options)
end

def delete_tags(tag_ids)
  tag_ids.each do |tag_id|
    tag = Tag.where(:tag_id => tag_id).first
    tag.delete if tag
  end
end

delete_tags(['global', 
            'london', 
            'learning', 
            'people', 
            'people/tech-team', 
            'people/commercial-team', 
            'people/executive-team', 
            'people/board',
            'people/operations-team',
            'news'])
    
create_or_update_tag(
    title: "Staff",
    tag_type: "person",
    tag_id: "people/staff",
    description: "Staff")

create_or_update_tag(
    title: "Trainer",
    tag_type: "person",
    tag_id: "people/trainers",
    description: "Trainer")

create_or_update_tag(
    title: "Member",
    tag_type: "person",
    tag_id: "people/members",
    description: "Member")

create_or_update_tag(
    title: "Start Ups",
    tag_type: "person",
    tag_id: "people/start-ups",
    description: "Start-up member")

create_or_update_tag(
    title: "Writer",
    tag_type: "person",
    tag_id: "people/writers",
    description: "Writer")

create_or_update_tag(
    title: "Artist",
    tag_type: "person",
    tag_id: "people/artists",
    description: "Artists")
    
create_or_update_tag(
    title: "Consultation Response",
    tag_type: "timed_item",
    tag_id: "consultation-response",
    description: "Consultation Response")

create_or_update_tag(
    title: "Procurement Item",
    tag_type: "timed_item",
    tag_id: "procurement",
    description: "Procurement Item")
                
create_or_update_tag(
    title: "News Item",
    tag_type: "article",
    tag_id: "news",
    description: "News Item")
    
create_or_update_tag(
    title: "Blog Post",
    tag_type: "article",
    tag_id: "blog",
    description: "Blog Post")

create_or_update_tag(
    title: "Media Release",
    tag_type: "article",
    tag_id: "media",
    description: "Media Release")

create_or_update_tag(
    title: "Start Up",
    tag_type: "organization",
    tag_id: "start-up",
    description: "Start Up")

create_or_update_tag(
    title: "Member",
    tag_type: "organization",
    tag_id: "member",
    description: "Member")