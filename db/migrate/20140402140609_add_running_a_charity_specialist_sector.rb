class AddRunningACharitySpecialistSector < Mongoid::Migration

  def self.topics
    [
      { title: "Fundraising", slug: "fundraising"},
      { title: "Managing your charity", slug: "managing-charity"},
      { title: "Money and accounts", slug: "money-accounts"},
      { title: "Trustee role and board", slug: "trustee-role-board"},
      { title: "Staff and volunteers", slug: "staff-volunteers"},
      { title: "Your charity's work", slug: "charitys-work"},
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
    parent_tag = Tag.create!(tag_type: 'specialist_sector', tag_id: 'running-charity', title: 'Running a charity')
    puts "Created #{parent_tag.tag_id}"

    create_topics_for_parent(parent_tag, topics)
  end

  def self.down
    destroy_topics_for_parent('running-charity')
  end
end
