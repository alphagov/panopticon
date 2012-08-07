namespace :actions do
  task :create_snapshots => :environment do
    success_count = failure_count = skip_count = 0
    # Disable re-registration: this isn't making any changes that should be
    # reflected in Rummager or the router, and disabling them makes things
    # faster and less likely to break
    Artefact.observers.disable :update_search_observer, :update_router_observer do
      Artefact.all.each do |artefact|
        if artefact.actions.empty?
          artefact.record_action "snapshot"
          if artefact.save
            STDERR.puts "Recorded snapshot for '#{artefact.name}'" if verbose
            success_count += 1
          else
            STDERR.puts "Failed to save '#{artefact.name}'" if verbose
            failure_count += 1
          end
        else
          STDERR.puts "Skipping snapshot for '#{artefact.name}'" if verbose
          skip_count += 1
        end
      end
      STDERR.puts "#{success_count} succeeded"
      STDERR.puts "#{failure_count} failed"
      STDERR.puts "#{skip_count} skipped"
    end
  end
end
