
namespace :router do
  desc "Reregister all live artefacts with the router"
  task :reregister_live_artefacts => :environment do
    puts "Re-registering all live artefacts with the router"
    artefact_count = Artefact.where(:state => 'live').count
    Artefact.where(:state => 'live').each_with_index do |artefact, i|
      puts "  #{artefact.slug} (#{i}/#{artefact_count})..."
      r = RoutableArtefact.new(artefact)
      r.submit(:skip_commit => true)
    end
    puts "Committing routes"
    RoutableArtefact.new(nil).commit
  end
end
