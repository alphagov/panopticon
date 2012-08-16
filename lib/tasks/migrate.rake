namespace :migrate do
  desc "Add descriptions for section tags"
  task :add_tag_descriptions => :environment do
    descriptions = {
      'business' => 'Information about starting up and running a business in the UK, including help if you\'re self employed or a sole trader.',
      'crime-and-justice' => 'Simple information to help answer your questions on jury service, courts, sentencing, ASBOs and prisons.',
      'driving' => 'Book your driving test or renew your vehicle tax online, find out the legal requirements for buying, owning, importing or scrapping a car or motorcycle, and read about your rights and responsibilities as a driver.',
      'education' => 'Get help if you&#39;re at school, planning to go on to further or higher education, looking for training or interested in a student or career development loan.',
      'family' => 'Find out about the laws for getting married/civil partnerships, the process of divorce and separation, parental leave, how to adopt a child, and more.',
      'housing' => 'Your legal obligations and rights when renting, buying or owning a home, plus information about Council Tax, what to do if you\'re homeless and where to get help if you have a housing dispute.',
      'life-in-the-uk' => 'Becoming a British citizen, registering to vote, information about government and the monarchy in the UK, and how to raise an e-petition.',
      'money-and-tax' => 'Find out about pensions, benefits, and what to do if you have debts. Also includes a comprehensive section on tax, including how you pay it and which tax credits you&#39;re eligible for.',
      'neighbourhoods' => 'Report local problems like abandoned vehicles, litter and noise pollution and find out information about your community.',
      'travel' => 'Plan a journey in the UK, see where you can use your bus pass and find out what you need to do before going abroad.',
      'work' => 'Find out about your rights and responsibilities as an employee, the benefits that can help you get back into work, the National Minimum Wage and your holiday entitlement.'
    }
    descriptions.each do |tag_id, description|
      tag = Tag.where(tag_id: tag_id).first
      tag.update_attributes!(description: description)
      puts "Added description to tag: #{tag.tag_id}"
    end
  end

  desc "Move Artefacts from the 'live' column to having a 'state' column"
  task :move_artefacts_to_state_column => :environment do
    Artefact.all.each do |artefact|
      if artefact[:live]
        artefact.state = "live"
      else
        artefact.state = "draft"
      end
      artefact.save!
    end
  end
end
