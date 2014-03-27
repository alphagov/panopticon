class AddCompetetionSectors < Mongoid::Migration
  def self.competition_sector_topics
    [
      { title: 'Mergers', slug: 'mergers'},
      { title: 'Markets', slug: 'markets'},
      { title: 'CA98 and civil cartels', slug: 'ca98-civil-cartels'},
      { title: 'Criminal cartels', slug: 'criminal-cartels'},
      { title: 'Regulatory appeals and references', slug: 'regulatory-appeals-references'},
      { title: 'Consumer law enforcement', slug: 'consumer-law-enforcement'},
      { title: 'Reviews of orders and undertakings', slug: 'reviews-orders-undertakings'},
      { title: 'Consumer protection regulations', slug: 'consumer-protection-regulations'},
      { title: 'Unfair terms regulations/compliance', slug: 'unfair-terms-regulations-compliance'},
      { title: 'Business law compliance', slug: 'business-law-compliance'},
      { title: 'Competition law compliance', slug: 'competition-law-compliance'},
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
    competition_tag = Tag.create!(tag_type: 'specialist_sector', tag_id: 'competition', title: 'Competition')
    puts "Created #{competition_tag.tag_id}"

    create_topics_for_parent(competition_tag, competition_sector_topics)
  end

  def self.down
    destroy_topics_for_parent('competition')
  end
end
