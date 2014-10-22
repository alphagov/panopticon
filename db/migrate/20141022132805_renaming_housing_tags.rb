class RenamingHousingTags < Mongoid::Migration

  OLD_PARENT_TAG = "housing"
  NEW_PARENT_TAG = "housing-local-services"

  OLD_PARENT_TAG_SEARCH_TERM = "housing/"
  NEW_PARENT_TAG_SEARCH_TERM = "housing-local-services/"


  def self.up

    puts "[1/5] Creating parent tag"
    parent = Tag.find_or_create_by(tag_id: NEW_PARENT_TAG, title: "Housing and local services", tag_type: "section")
    parent.publish
    puts "\tCreated #{parent.inspect}"

    puts "[2/5] Creating child tags for new parent"
    create_categories_for_parent(false)

    puts "[3/5] retagging artefacts"
    retag_artefacts

    puts "[4/5] removing old child tags"
    destroy_categories_for_parent

    puts "[5/5] removing old parent tag"
    parent_tag = Tag.where(tag_id: OLD_PARENT_TAG, tag_type: 'section').first
    if parent_tag.destroy
      puts "\tDeleted #{parent_tag.tag_id}"
    else
      puts "\tCould not find parent tag to delete"
    end
  end

  def self.down

    puts "[1/5] Recreating old parent tag"
    parent = Tag.find_or_create_by(tag_id: OLD_PARENT_TAG, title: "Housing and local services", tag_type: "section")
    parent.publish
    puts "\tCreated #{parent.inspect}"

    puts "[2/5] Creating child tags for old parent"
    create_categories_for_parent

    puts "[3/5] retagging artefacts"
    retag_artefacts(false)

    puts "[4/5] Deleting child tags for new parent"
    destroy_categories_for_parent(false)

    puts "[5/5] Deleting new parent tag"
    parent_tag = Tag.where(tag_id: NEW_PARENT_TAG, tag_type: 'section').first
    if  parent_tag.destroy
      puts "\tDeleted #{parent_tag.tag_id}"
    else
      puts "\tCould not find parent tag to delete"
    end

  end

  def self.retag_artefacts(new_parent=true)

    from, to = new_parent ? [OLD_PARENT_TAG_SEARCH_TERM, NEW_PARENT_TAG_SEARCH_TERM] : [NEW_PARENT_TAG_SEARCH_TERM, OLD_PARENT_TAG_SEARCH_TERM]

    artefacts = Artefact.any_in(tag_ids: [Regexp.new(from)])

    puts "Found artefacts:\n#{artefacts.all.map(&:slug)}"

    artefacts.all.each do |a|

      puts "Artefact '#{a.slug}' has sections_ids : #{a.section_ids} and a state : #{a.state}"

      unless a.state == "archived"
        a.section_ids = a.section_ids.map do |t|
          t.gsub(from, to)
        end
        
        if a.save
          puts "\t -> Rewritten section_ids to #{a.section_ids} for #{a.slug}"
        else
          puts "\t -> Couldn't update #{a.slug}"
        end
      end
    end

  end

  def self.categories
    [
      { title: "Council Tax", slug: "council-tax"},
      { title: "Council housing and housing association", slug: "council-housing-association"},
      { title: "Being a landlord and renting out a room", slug: "landlords"},
      { title: "Local councils and services", slug: "local-councils"},
      { title: "Noise, neighbours, pets and pests", slug: "noise-neighbours"},
      { title: "Owning and renting a property", slug: "owning-renting-property"},
      { title: "Planning permission and building regulations", slug: "planning-permission"},
      { title: "Recycling, rubbish, streets and roads", slug: "recycling-rubbish"},
      { title: "Repossessions, emergency housing and evictions", slug: "repossessions-evictions"},
      { title: "Safety and the environment in your community", slug: "safety-environment"},
    ]
  end

  def self.create_categories_for_parent(new_parent=true)
    parent_tag = new_parent ? OLD_PARENT_TAG : NEW_PARENT_TAG

    categories.each do |category|
      created = Tag.create!(tag_id: "#{parent_tag}/#{category[:slug]}", title: category[:title], tag_type: 'section', parent_id: parent_tag)
      created.publish
      puts "\tCreated #{created.inspect}"
    end
  end

  def self.destroy_categories_for_parent(new_parent=true)
    parent_tag = new_parent ? OLD_PARENT_TAG : NEW_PARENT_TAG

    Tag.where(parent_id: parent_tag).each do |tag|
      tag.destroy
      puts "\tDeleted #{tag.tag_id}"
    end
  end

end
