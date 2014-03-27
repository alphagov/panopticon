class AddEnvironmentalManagementSector < Mongoid::Migration

  def self.topics
    [
      { title: 'Boating', slug: 'boating'},
      { title: 'Climate change and energy', slug: 'climate-change-energy'},
      { title: 'Chemicals', slug: 'chemicals'},
      { title: 'Environmental permits', slug: 'environmental-permits'},
      { title: 'Environmental risk management', slug: 'environmental-risk-management'},
      { title: 'Fisheries and rod licensing', slug: 'fisheries-rod-licensing'},
      { title: 'Flooding and coastal change', slug: 'flooding-coastal-change'},
      { title: 'Land management', slug: 'land-management'},
      { title: 'Marine', slug: 'marine'},
      { title: 'Oil storage', slug: 'oil-storage'},
      { title: 'Waste', slug: 'waste'},
      { title: 'Water', slug: 'water'},
      { title: 'Wildlife and habitat conservation', slug: 'wildlife-habitat-conservation'},
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
    parent_tag = Tag.create!(tag_type: 'specialist_sector', tag_id: 'environmental-management', title: 'Environmental management ')
    puts "Created #{parent_tag.tag_id}"

    create_topics_for_parent(parent_tag, topics)
  end

  def self.down
    destroy_topics_for_parent('environmental-management')
  end
end
