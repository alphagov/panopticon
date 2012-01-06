namespace :sections do
  
  desc "Migrate section assignments to new sections"
  task :migrate => :environment do
    
    @section_migrations = {
      'Tax'         => 'Money and Tax',
      'Money'       => 'Money and Tax',
      'Citizenship' => 'Life in the UK'
    }
    
    Artefact.all.each do |a|
      
      current_section = a.section
      new_section = @section_migrations[current_section]
      
      if !new_section or new_section.nil?
        puts "Not updating \"#{a.name}\" (\"#{current_section}\")".colorize(:white) 
      elsif a.update_attribute(:section, new_section)
        puts "Updated \"#{a.name}\" from \"#{current_section}\" to \"#{new_section}\"".colorize(:green)
      else
        puts "Error: Could not update \"#{a.name}\", existing section \"#{current_section}\"".colorize(:red)
      end
    end
  end
end