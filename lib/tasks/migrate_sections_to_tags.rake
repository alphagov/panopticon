namespace :sections do

  desc "Copy sections to be tags"
  task :migrate_to_tags => :environment do

    # for each section
    Section.all.map do |s|
      # split on :
      section, sub = s.slug.split(':')
      tagified_section = section.downcase.gsub(' ', '-')
      t = TagRepository.load(tagified_section)
      unless t
        new_tag = {:tag_id => tagified_section, :title => section, :tag_type => 'section'}
        TagRepository.put(new_tag)
      end

      tagfied_sub = "#{tagified_section}/#{sub.downcase.gsub(' ', '-')}"
      sub_t = TagRepository.load(tagfied_sub)
      unless sub_t
        new_tag = {:tag_id => tagfied_sub, :title => sub, :tag_type => 'section'}
        TagRepository.put(new_tag)
      end
    end

    Artefact.all.each do |a|
      next if a.need_id.blank?

      # HACK: correct the one section that was hard-coded, then changed
      a.section = 'Work:Time off work' if a.section == 'Work:Time off'

      begin
        a.save!
      rescue RuntimeError
        puts "Failed to migrate section '#{a.section}' to tags"
      end
    end

  end
end