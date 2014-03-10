class AddDfeSpecialistSectors < Mongoid::Migration

  def self.schools_topics
    [
      { title: "Administration and finance", slug: "administration-finance" },
      { title: "Behaviour and attendance", slug: "behaviour-attendance" },
      { title: "Careers and employment", slug: "careers-employment" },
      { title: "Curriculum and qualifications", slug: "curriculum-qualifications" },
      { title: "Data collection and statistical returns", slug: "data-collection" },
      { title: "Early learning and childcare", slug: "early-learning-childcare" },
      { title: "Governance", slug: "governance" },
      { title: "Procurement", slug: "procurement" },
      { title: "Special educational needs and disabilities (SEND)", slug: "special-educational-needs" },
      { title: "Support for children and young people", slug: "young-peoples-support" },
      { title: "Types of schools", slug: "schools-types" },
    ]
  end

  def self.children_topics
    [
      { title: "Adoption", slug: "adoption" },
      { title: "Child poverty", slug: "child-poverty" },
      { title: "Children's social care", slug: "childrens-social-care" },
      { title: "Data collection and statistical returns", slug: "data-collection" },
      { title: "Early learning and childcare", slug: "early-learning-childcare" },
      { title: "Family support", slug: "family-support" },
      { title: "Foster care", slug: "foster-care" },
      { title: "Special educational needs and disabilities (SEND) ", slug: "special-educational-needs" },
      { title: "Support for children and young people", slug: "young-peoples-support" },
    ]
  end

  def self.create_topics_for_parent(parent, topics)
    topics.each do |topic|
      created = Tag.create!(tag_id: "#{parent.tag_id}/#{topic[:slug]}", title: topic[:title], tag_type: 'specialist_sector', parent_id: parent.tag_id)
      puts "Created #{created.tag_id}"
    end
  end

  def self.destroy_topics_for_parent(parent_id)
    parent_tag = Tag.by_tag_id(parent_id)
    parent_tag.destroy
    puts "Deleted #{parent_tag.tag_id}"

    Tag.where(parent_id: parent_id).each do |tag|
      tag.destroy
      puts "Deleted #{tag.tag_id}"
    end
  end

  def self.up
    schools_tag = Tag.create!(tag_id: "schools-colleges", title: "Schools and colleges", tag_type: "specialist_sector")
    puts "Created #{schools_tag.tag_id}"

    children_tag = Tag.create!(tag_id: "childrens-services", title: "Children's services", tag_type: "specialist_sector")
    puts "Created #{children_tag.tag_id}"

    create_topics_for_parent(schools_tag, schools_topics)
    create_topics_for_parent(children_tag, children_topics)
  end

  def self.down
    destroy_topics_for_parent("schools-colleges")
    destroy_topics_for_parent("childrens-services")
  end

end
