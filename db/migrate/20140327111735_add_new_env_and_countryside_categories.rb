class AddNewEnvAndCountrysideCategories < Mongoid::Migration

  OLD_SECTION_TAG = 'citizenship/coasts-countryside'

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

  def self.mainstream_content_to_retag
    [
      ["buy-a-uk-fishing-rod-licence", "environment-countryside/fishing-hunting"],
      ["right-of-way-open-access-land", "environment-countryside/countryside"],
      ["hunting-and-the-law", "environment-countryside/fishing-hunting"],
      ["managing-wildlife-on-your-land", "environment-countryside/wildlife-biodiversity"],
      ["protecting-rural-landscapes-and-features", "environment-countryside/countryside"],
      ["nonnative-wildlife", "environment-countryside/wildlife-biodiversity"],
      ["report-stranded-whale-dolphin", "environment-countryside/wildlife-biodiversity"],
      ["report-wreck-material", "environment-countryside/treasure-wrecks"],
      ["apply-for-a-thames-accommodation-licence", "housing/planning-permission"],
      ["check-plans-to-stop-coastal-erosion-in-your-area", "environment-countryside/coasts"],
      ["check-if-youre-at-risk-of-flooding", "environment-countryside/flooding-extreme-weather"],
      ["check-river-conditions-and-closures", "environment-countryside/boats-waterways"],
      ["quality-of-local-bathing-water", "environment-countryside/coasts"],
      ["fishing-licences", "environment-countryside/fishing-hunting"],
      ["flood-defence-consent-england-wales", "housing/planning-permission"],
      ["prepare-for-a-flood", "environment-countryside/flooding-extreme-weather"],
      ["treasure", "environment-countryside/treasure-wrecks"],
      ["sign-up-for-flood-warnings", "environment-countryside/flooding-extreme-weather"],
    ]
  end

  def self.mainstream_content_to_add_new_tags
    [
      ["managing-your-waste-an-overview", "environment-countryside/recycling-waste-management"],
      ["battery-waste-supplier-reponsibilities", "environment-countryside/recycling-waste-management"],
      ["check-your-business-protected-area", "housing/planning-permission"],
      ["site-waste-construction-plans", "environment-countryside/recycling-waste-management"],
      ["contaminated-land", "environment-countryside/recycling-waste-management"],
      ["electricalwaste-producer-supplier-responsibilities", "environment-countryside/recycling-waste-management"],
      ["hazardous-waste-disposal", "environment-countryside/recycling-waste-management"],
      ["find-registered-waste-carrier", "environment-countryside/recycling-waste-management"],
      ["get-an-environmental-permit", "environment-countryside/recycling-waste-management"],
      ["green-taxes-and-reliefs", "environment-countryside/recycling-waste-management"],
      ["dispose-hazardous-waste", "environment-countryside/recycling-waste-management"],
      ["hazardous-waste-producer-registration", "environment-countryside/recycling-waste-management"],
      ["register-as-a-hazardous-waste-producer", "environment-countryside/recycling-waste-management"],
      ["how-to-classify-different-types-of-waste", "environment-countryside/recycling-waste-management"],
      ["how-to-dispose-of-nonhazardous-waste", "environment-countryside/recycling-waste-management"],
      ["packaging-waste-designer-responsibilities", "environment-countryside/recycling-waste-management"],
      ["preventing-air-pollution", "environment-countryside/recycling-waste-management"],
      ["permits-you-need-for-septic-tanks", "environment-countryside/recycling-waste-management"],
      ["permits-you-need-for-septic-tanks", "housing/planning-permission"],
      ["report-an-environmental-incident", "environment-countryside/recycling-waste-management"],
      ["operating-landfill-site", "environment-countryside/recycling-waste-management"],
      ["register-waste-carrier", "environment-countryside/recycling-waste-management"],
    ]
  end

  def self.create_categories_for_parent(parent, categories)
    categories.each do |category|
      created = Tag.create!(tag_id: "#{parent.tag_id}/#{category[:slug]}", title: category[:title], tag_type: 'section', parent_id: parent.tag_id)
      puts "\tCreated #{created.tag_id}"
    end
  end

  def self.destroy_categories_for_parent(parent_id)
    Tag.where(parent_id: parent_id).each do |tag|
      tag.destroy
      puts "\tDeleted #{tag.tag_id}"
    end
  end

  def self.up
    puts "[1/5] Creating parent tag"
    parent_tag = Tag.create!(tag_type: 'section', tag_id: 'environment-countryside', title: 'Environment and countryside')
    puts "\tCreated #{parent_tag.tag_id}"

    puts "[2/5] Creating child tags"
    create_categories_for_parent(parent_tag, categories)

    puts "[3/5] Retagging mainstream content"
    mainstream_content_to_retag.each do |(slug, new_tag)|
      puts "\t- #{slug}"
      artefact = Artefact.find_by_slug(slug)
      artefact.section_ids = (artefact.section_ids - [OLD_SECTION_TAG] + [new_tag])
      if artefact.save
        puts "\t\tSaved: #{OLD_SECTION_TAG} -> #{new_tag}"
      else
        puts "\t\tNot saved: #{artefact.errors.full_messages}"
      end
    end

    puts "[4/5] Adding additional tags to mainstream content"
    mainstream_content_to_add_new_tags.each do |(slug, new_tag)|
      puts "\t- #{slug}"
      artefact = Artefact.find_by_slug(slug)
      artefact.section_ids = (artefact.section_ids + [new_tag])
      if artefact.save
        puts "\t\tAdded: #{new_tag}"
      else
        puts "\t\tNot saved: #{artefact.errors.full_messages}"
      end
    end

    puts "[5/5] Remove existing tag"
    tag = Tag.where(tag_id: OLD_SECTION_TAG, tag_type: 'section')
    tag.destroy
    puts "\tDeleted #{OLD_SECTION_TAG}"
  end

  def self.down
    puts "[1/5] Re-create #{OLD_SECTION_TAG}"
    parent_tag = Tag.create!(tag_type: 'section', tag_id: OLD_SECTION_TAG, title: 'Coasts, countryside and creatures')
    puts "\tCreated"

    puts "[2/5] Remove additional tags from mainstream content"
    mainstream_content_to_add_new_tags.each do |(slug, new_tag)|
      puts "\t- #{slug}"
      artefact = Artefact.find_by_slug(slug)
      artefact.section_ids = (artefact.section_ids - [new_tag])
      if artefact.save
        puts "\t\tRemoved: #{new_tag}"
      else
        puts "\t\tNot saved: #{artefact.errors.full_messages}"
      end
    end

    puts "[3/5] Retagging mainstream content"
    mainstream_content_to_retag.each do |(slug, new_tag)|
      puts "\t- #{slug}"
      artefact = Artefact.find_by_slug(slug)
      artefact.section_ids = (artefact.section_ids - [new_tag] + [OLD_SECTION_TAG])
      if artefact.save
        puts "\t\tSaved: #{new_tag} -> #{OLD_SECTION_TAG}"
      else
        puts "\t\tNot saved: #{artefact.errors.full_messages}"
      end
    end

    puts "[4/5] Deleting child tags"
    destroy_categories_for_parent('environment-countryside')

    puts "[5/5] Deleting parent tag"
    parent_tag = Tag.where(tag_id: 'environment-countryside', tag_type: 'section').first
    if parent_tag
      parent_tag.destroy
      puts "\tDeleted #{parent_tag.tag_id}"
    else
      puts "\tCould not find parent tag to delete"
    end
  end

end
