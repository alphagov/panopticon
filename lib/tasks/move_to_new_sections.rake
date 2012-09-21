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
      puts row.inspect
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
end