module NewSectionMigration
  def self.delete_all_section_tags
    deleted_count = Tag.where(tag_type: 'section').delete_all
  end

  def self.wipe_sections_from_artefacts
    Artefact.all.each do |artefact|
      artefact.sections = []
      begin
        artefact.save!
      rescue StandardError => e
        puts "Encountered error when saving artefact: #{artefact.slug}: #{e.to_s}. Sections stored in the database are now: #{artefact.reload.sections}"
      end
    end
  end

  def self.import_new_sections(csv_path)
    ensure_file_exists!(csv_path)
    csv_obj = CSV.new(File.read(csv_path), {headers: :first_row, return_headers: false})
    # eg: [title, slug, desc, parent_slug]
    csv_obj.each do |row|
      row = row.map { |k,v| v && v.strip }

      parent = nil
      if !row[3].blank?
        parent = Tag.where(tag_type: 'section', tag_id: clean_slug(row[3])).first
        if parent.nil?
          raise "Stop! Parent section #{clean_slug(row[3])} could not be found."
        end
      end

      full_slug = construct_full_slug(row[3], row[1])
      if row[1] != full_slug.split("/").last # hack to get the cleaned up child slug
        puts "Warning: Had to modify slug from '#{row[1]}' to '#{full_slug.split("/").last}'"
      end

      t = Tag.create!(tag_type: 'section', title: row[0], tag_id: full_slug,
                  description: row[2], parent_id: parent ? parent.tag_id : nil)
      
      # NOTE CuratedList currently validates it's slug as a slug.
      # That means it can't include a slash, but subsection urls have slashes...
      # 
      # If the tag has a parent, that makes it a subsection. 
      # If it's a subsection we want it to have a CuratedList.
      # if t.has_parent?
      #   CuratedList.create!(slug: full_slug, sections: [t.tag_id])
      # end
    end
  end

  def self.export_artefacts(csv_save_path)
    query = Artefact.where(:state.nin => ["archived"]).order([:name, :asc])
    a_file = File.open(csv_save_path, 'w+')
    # Don't trust the Artefact state flag
    really_live_artefacts = query.reject do |artefact|
      (artefact.owning_app == "publisher") &&
          (Edition.where(panopticon_id: artefact.id, :state.nin => ["archived"]).count == 0)
    end
    puts "Exporting #{really_live_artefacts.size} artefacts that are live or in progress"
    really_live_artefacts.each do |a|
      a_file.write([a.name, a.slug].to_csv)
    end
    a_file.close
  end

  def self.tag_content_with_new_sections(content_csv)
    ensure_file_exists!(content_csv)
    csv_obj = CSV.new(File.read(content_csv), {headers: :first_row, return_headers: false})
    # eg: [title,slug_of_content,section_slug,section_slug,section_slug...]
    csv_obj.each do |csv_row|
      row = csv_row.fields
      next if row[1].blank?
      clean_slug = clean_slug(row[1])
      a = Artefact.where(slug: clean_slug).first
      if a.nil?
        puts "Had to ignore Artefact '#{clean_slug}' - could not be found. It's probably been renamed."
        next
      end
      row.shift # remove the artefact title
      row.shift # remove the artefact slug
      sections = []
      clean_section_slugs = row.compact.map { |slug_with_slashes| slug_with_slashes.strip.gsub(%r{^/}, "") }
      clean_section_slugs.each do |clean_section_slug|
        if clean_section_slug
          tag = Tag.where(tag_type: 'section', tag_id: clean_section_slug).first
          if tag.nil?
            raise "Stop! New section '#{clean_section_slug}' for Artefact: #{a.slug} was not found."
          end
          sections << tag.tag_id
        end
      end
      a.sections = sections
      begin
        a.save!
      rescue StandardError => e
        puts "Encountered error when saving artefact: #{artefact.slug}: #{e.to_s}. Sections stored in the database are now: #{artefact.reload.sections}"
      end
    end
  end

  private
    def self.ensure_file_exists!(filepath)
      raise "FATAL: File must be specified" if filepath.blank?
      raise "FATAL: File not found #{filepath}" if !File.exist?(filepath)
    end

    def self.clean_slug(raw_slug)
      raw_slug.nil? ? nil : raw_slug.parameterize
    end

    def self.construct_full_slug(parent_slug, child_slug)
      [parent_slug, child_slug]
        .reject(&:blank?)
        .map(&:parameterize)
        .join("/")
    end
end

namespace :migrate do
  desc "Remove old sections, insert new ones, setup curated list"
  task :delete_all_section_tags => :environment do
    deleted_count = NewSectionMigration.delete_all_section_tags
    puts "Deleted #{deleted_count} section tags"

    puts "Clearing sections on all #{Artefact.count} artefacts..."
    NewSectionMigration.wipe_sections_from_artefacts
  end

  task :import_new_sections, [:section_csv] => :environment do |t, args|
    NewSectionMigration.import_new_sections(args[:section_csv])
  end

  task :export_all_artefacts, [:artefact_csv] => :environment do |t, args|
    NewSectionMigration.export_artefacts(args[:artefact_csv])
  end

  task :tag_content_with_new_sections, [:content_csv] => :environment do |t, args|
    NewSectionMigration.tag_content_with_new_sections(args[:content_csv])
  end
end
