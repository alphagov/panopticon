namespace :taggings do
  desc "Migrate taggings for an app (rake taggings:migrate_all OWNING_APP=smartanswers)"
  task migrate_all: [:environment] do
    TaggingMigrator.new(ENV.fetch('OWNING_APP')).migrate!
  end

  desc "Migrate mainstream browse taggings only (rake taggings:migrate_browse OWNING_APP=smartanswers)"
  task migrate_browse: [:environment] do
    MainstreamBrowseMigrator.new(ENV.fetch('OWNING_APP')).migrate!
  end
end
