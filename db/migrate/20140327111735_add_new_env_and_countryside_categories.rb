class AddNewEnvAndCountrysideCategories < Mongoid::Migration
    def self.categories
    [
      { title: 'Boats and waterways', slug: 'boats-waterways'},
      { title: 'Coasts', slug: 'coasts'},
      { title: 'Countryside', slug: 'countryside'},
      { title: 'Fishing and hunting', slug: 'fishing-hunting'},
      { title: 'Flooding and extreme weather', slug: 'flooding-extreme-weather'},
      { title: 'Recycling and waste management', slug: 'recycling-waste-management'},
      { title: 'Treasure and wrecks', slug: 'treasure-wrecks'},
      { title: 'Wildlife and biodiversity', slug: 'wildlife-biodiversity'},
    ]
  end

  def self.create_categories_for_parent(parent, categories)
    categories.each do |category|
      created = Tag.create!(tag_id: "#{parent.tag_id}/#{category[:slug]}", title: category[:title], tag_type: 'section', parent_id: parent.tag_id)
      puts "Created #{created.tag_id}"
    end
  end

  def self.destroy_categories_for_parent(parent_id)
    parent_tag = Tag.by_tag_id(parent_id)
    parent_tag.destroy
    puts "Deleted #{parent_tag.tag_id}"

    Tag.where(parent_id: parent_id).each do |tag|
      tag.destroy
      puts "Deleted #{tag.tag_id}"
    end
  end

  def self.up
    parent_tag = Tag.create!(tag_type: 'section', tag_id: 'environment-countryside', title: 'Environment and countryside ')
    puts "Created #{parent_tag.tag_id}"

    create_categories_for_parent(parent_tag, categories)
  end

  def self.down
    destroy_categories_for_parent('environment-countryside')
  end

end
