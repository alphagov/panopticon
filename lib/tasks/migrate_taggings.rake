desc "Migrate taggings for an app (rake migrate_taggings OWNING_APP=smartanswers)"
task migrate_taggings: [:environment] do
  TaggingMigrator.new(ENV.fetch('OWNING_APP')).migrate!
end
