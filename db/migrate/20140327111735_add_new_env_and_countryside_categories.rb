class AddNewEnvAndCountrysideCategories < Mongoid::Migration

  def self.changes
    [
      { slug: 'buy-a-uk-fishing-rod-licence', old_cat: 'citizenship/coasts-countryside', new_cat: 'fishing-and-hunting'},
      { slug: 'right-of-way-open-access-land', old_cat: 'citizenship/coasts-countryside', new_cat: 'countryside'},
      { slug: 'hunting-and-the-law', old_cat: 'citizenship/coasts-countryside', new_cat: 'fishing-and-hunting'},
      { slug: 'managing-wildlife-on-your-land', old_cat: 'citizenship/coasts-countryside', new_cat: 'wildlife-and-biodiversity'},
      { slug: 'protecting-rural-landscapes-and-features', old_cat: 'citizenship/coasts-countryside', new_cat: 'countryside'},
      { slug: 'nonnative-wildlife', old_cat: 'citizenship/coasts-countryside', new_cat: 'wildlife-and-biodiversity'},
      { slug: 'report-stranded-whale-dolphin', old_cat: 'citizenship/coasts-countryside', new_cat: 'wildlife-and-biodiversity'},
      { slug: 'report-wreck-material', old_cat: 'citizenship/coasts-countryside', new_cat: 'treasure-and-wrecks'},
      { slug: 'check-plans-to-stop-coastal-erosion-in-your-area', old_cat: 'citizenship/coasts-countryside', new_cat: 'coasts'},
      { slug: 'check-if-youre-at-risk-of-flooding', old_cat: 'citizenship/coasts-countryside', new_cat: 'flooding-and-extreme-weather'},
      { slug: 'quality-of-local-bathing-water', old_cat: 'citizenship/coasts-countryside', new_cat: 'coasts'},
      { slug: 'fishing-licences', old_cat: 'citizenship/coasts-countryside', new_cat: 'fishing-and-hunting'},
      { slug: 'flood-defence-consent-england-wales', old_cat: 'citizenship/coasts-countryside', new_cat: 'flooding-and-extreme-weather'},
      { slug: 'prepare-for-a-flood', old_cat: 'citizenship/coasts-countryside', new_cat: 'flooding-and-extreme-weather'},
      { slug: 'treasure', old_cat: 'citizenship/coasts-countryside', new_cat: 'treasure-and-wrecks'},
      { slug: 'sign-up-for-flood-warnings', old_cat: 'citizenship/coasts-countryside', new_cat: 'flooding-and-extreme-weather'},
      { slug: 'camping-and-caravan-sites-minimise-your-flood-risk', old_cat: 'citizenship/coasts-countryside > Flooding and coastal change', new_cat: 'flooding-and-extreme-weather'},
      { slug: 'flood-risk-management-information-for-flood-risk-management-authorities-asset-owners-and-local-authorities', old_cat: 'citizenship/coasts-countryside > Flooding and coastal change', specialist_topic_tag: 'flooding-and-coastal-change'},
      { slug: 'flood-risk-management-information-for-flood-risk-management-authorities-asset-owners-and-local-authorities', old_cat: 'citizenship/coasts-countryside > Flooding and coastal change', specialist_topic_tag: 'flooding-and-coastal-change'},
      { slug: 'reservoirs-a-guide-for-owners-and-operators', old_cat: 'citizenship/coasts-countryside > Flooding and coastal change', specialist_topic_tag: 'water'},
      { slug: 'biodiversity-offsetting', old_cat: 'citizenship/coasts-countryside > Wildlife and habitat conservation', specialist_topic_tag: 'wildlife-and-habitat-conservation'},
    ]
  end

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

  def self.tag_content(change)
    page = Artefact.find_by_slug(change[:slug])
    if page
      tags = page.tag_ids

      if change[:new_cat]
        tags.delete(change[:old_cat])
        tags += ["environment-countryside/#{change[:new_cat]}"]
        tags.uniq!
      elsif change[:specialist_topic_tag]
        tags += ["environmental-management/#{change[:specialist_topic_tag]}"]
        tags.uniq!
      end

      page.tag_ids = tags
      page.save!
    end
  end

  def self.up 
    parent_tag = Tag.create!(tag_type: 'section', tag_id: 'environment-countryside', title: 'Environment and countryside')
    puts "Created #{parent_tag.tag_id}"

    create_categories_for_parent(parent_tag, categories)

    changes.each do |change|
      tag_content(change)
    end

  end

  def self.down
    destroy_categories_for_parent('environment-countryside')
  end

end
