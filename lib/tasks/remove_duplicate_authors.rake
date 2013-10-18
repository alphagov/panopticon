namespace :authors do
  task :remove => :environment do    
    Artefact.where(:tag_ids => 'team').each do |person|
      Artefact.where(:slug => person.slug).not_in(:tag_ids => ['team']).first.delete rescue nil
    end

    Artefact.skip_callback(:update, :after, :update_editions)

    Artefact.where(:slug => 'jeni-tennison').first.delete rescue nil
    a = Artefact.where(:slug => 'jeni').first
    a.slug = "jeni-tennison"
    a.tag_ids = ["executive", "technical", "team"]
    a.save

    Artefact.where(:slug => 'gavin-starks').first.delete rescue nil
    a = Artefact.where(:slug => 'gavin').first
    a.slug = "gavin-starks"
    a.tag_ids = ["board", "executive", "team"]
    a.save

    user = User.all.last

    Artefact.where(:author => 'davetaz').each do |a|
      a.update_attributes_as(user, {author: "dr-david-tarrant"})
    end

    Artefact.where(:author => 'phillang').each do |a|
      a.update_attributes_as(user, {author: "phil-lang"})
    end

    Artefact.set_callback(:update, :after, :update_editions)
  end
end