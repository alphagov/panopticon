namespace :sections do

  desc "Migrate artefacts to use tags for section information"
  task :artefact_sections_to_tags => :environment do

    IMPORTING_LEGACY_DATA = true  # Allow resaving artefacts with no need ID

    # Artefacts where section doesn't exist: leave them
    # Artefacts where section is nil or empty string: unset section
    # Artefacts where section is top-level:
    #   set top-level section tag;
    #   set primary section;
    #   unset section
    # Artefacts where section is sub-level:
    #   set [sub-level, top-level];
    #   set primary section to sub-level;
    #   unset section

    # The current stable version of Mongo doesn't offer criteria updates
    Artefact.any_in(:section => [nil, '']).each do |a|
      a.unset 'section'
      a.save!
    end

    Artefact.where(:section.exists => true).each do |a|
      section = a['section']

      # Skip empty values: only useful in development
      next if [nil, ''].include? section

      section_parts = section.split(':').map { |s| s.downcase.gsub(' ', '-') }

      case section_parts.length
      when 1
        section_tags = section_parts
      when 2
        section_tags = [section_parts.join('/'), section_parts[0]]
      else
        puts 'Wrong number of sections: aargh!'
        raise RuntimeError
      end
      a.sections = section_tags  # Will check the tags exist
      a.primary_section = section_tags[0]
      a.save!
      puts "Sections: #{a.sections}; primary: #{a.primary_section}"

      # Word of warning: this *does* persist the artefact, even without save
      a.unset 'section'
      # a.save!
    end

  end
end