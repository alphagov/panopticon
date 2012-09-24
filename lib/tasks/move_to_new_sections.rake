namespace :migrate do
  desc "Remove old sections, insert new ones, setup curated list"
  task :delete_all_section_tags => :environment do
    Tag.where(type: 'section').delete_all

    Artefact.all.each do |artefact|
      artefact.sections = []
      artefact.save!
    end
  end

  task :import_new_sections, [:section_csv] => :environment do |t, args|
    csv_obj = CSV.new(File.read(args[:section_csv]), {headers: :first_row, return_headers: false})
    # eg: [title, slug, desc, parent_slug]
    csv_obj.each do |row|
      row = row.map { |k,v| v && v.strip }

      parent = nil
      if !row[3].blank?
        parent = Tag.where(tag_type: 'section', tag_id: row[3]).first
        if parent.nil?
          raise "Stop! Parent section #{row[3]} could not be found."
        end
      end

      clean_slug = row[1].parameterize
      if row[1] != clean_slug
        puts "Warning: Had to modify slug from '#{row[1]}' to '#{clean_slug}'"
      end

      t = Tag.create!(tag_type: 'section', title: row[0], tag_id: clean_slug,
                  description: row[2], parent_id: parent ? parent.tag_id : nil)
      if t.has_parent?
        CuratedList.create!(slug: clean_slug, sections: [t.tag_id])
      end
    end
  end

  task :export_all_live_artefacts, [:artefact_csv] => :environment do |t, args|
    a_file = File.open(args[:artefact_csv], 'w+')
    Artefact.where(state: 'live').each do |a|
      a_file.write("#{a.slug}\n")
    end
    a_file.close
  end

  task :tag_content_with_new_sections, [:content_csv] => :environment do |t, args|
    csv_obj = CSV.new(File.read(args[:content_csv]), {headers: :first_row, return_headers: false})
    # eg: [slug_of_content,section_slug,section_slug,section_slug]
    csv_obj.each do |csv_row|
      row = csv_row.fields
      puts row.inspect
      a = Artefact.where(slug: row[0]).first
      if a.nil?
        raise "Stop! Artefact #{row[0]} could not be found."
      end
      row.shift
      sections = []
      row.each do |new_section|
        unless new_section.nil?
          tag = Tag.where(tag_type: 'section', tag_id: new_section).first
          if tag.nil?
            raise "Stop! New section #{new_section} for Artefact:#{a.slug} was not found."
          end
          sections << tag.tag_id
        end
      end
      a.sections = sections
      a.save!
    end
  end
end
