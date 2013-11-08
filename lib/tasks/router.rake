
namespace :router do
  desc "Reregister all live artefacts with the router"
  task :reregister_live_artefacts => :environment do
    puts "Re-registering all live artefacts with the router"
    Artefact.where(:state => 'live').each do |artefact|
      puts "  #{artefact.slug}..."
      r = RoutableArtefact.new(artefact)
      r.submit(:skip_commit => true)
    end
    puts "Committing routes"
    RoutableArtefact.new(nil).commit
  end
end
