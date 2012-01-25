namespace :sections do
  
  desc "Migrate section assignments to new sections"
  task :migrate => :environment do
    
    @section_migrations = {
      'Crime and justice:Mental capacity and the law' => 'Family:Mental capacity and the law',
      'Education:Schools'                             => 'Education:In schools',
      'Work:Finding work'                             => 'Work:Finding a job',
      'Work:Time off from work'                       => 'Work:Time off',
      'Family:Childcare'                              => 'Family:Children',
      'Family:Separation and Divorce'                 => 'Family:Divorce and Separation',
      'Money and tax:Sickness, disability and carers' => 'Money and tax:Disability and carers',
      'Money and tax:Seasonal payments'               => 'Money and tax:Winter payments',
      'Housing:Council housing'                       => 'Housing:Council and Housing Association homes',
      'Life in the UK:Becoming a British citizen'     => 'Live in the UK:Rights and citizenship',
      'Travel:Animals and the UK'                     => 'Travel:Animals, food and plants',
      'Travel:Travelling in the UK'                   => 'Travel:Domestic travel',
      'Neighbourhoods:Community'                      => 'Neighbourhoods:Community and local services',
      'Neighbourhoods:Library and learning'           => 'Neighbourhoods:Libraries and learning',
      'Neighbourhoods:Open spaces'                    => 'Neighbourhoods:Parks and open spaces'
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