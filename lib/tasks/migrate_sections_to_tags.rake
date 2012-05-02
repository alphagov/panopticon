namespace :sections do

  desc "Copy sections to be tags"
  task :migrate_to_tags => :environment do

    # for each section
    Section.all.map do |s|
      # split on :
      section, sub = s.slug.split(':')
      tagified_section = section.downcase.gsub(' ', '-')
      puts tagified_section
      t = TagRepository.load(tagified_section)
      puts t
      unless t
        new_tag = {:tag_id => tagified_section, :title => section, :tag_type => 'section'}
        puts new_tag
        TagRepository.put(new_tag)
      end

      tagfied_sub = "#{tagified_section}/#{sub.downcase.gsub(' ', '-')}"
      puts "tagified_sub: #{tagfied_sub}"
      sub_t = TagRepository.load(tagfied_sub)
      unless sub_t
        new_tag = {:tag_id => tagfied_sub, :title => sub, :tag_type => 'section'}
        puts new_tag
        TagRepository.put(new_tag)
      end
    end

    Artefact.all.each { |a| a.save! }

  end
end