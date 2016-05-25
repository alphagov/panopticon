namespace :taggings do
  desc "Migrate taggings for an app (rake taggings:migrate_all OWNING_APP=smartanswers)"
  task migrate_all: [:environment] do
    TaggingMigrator.new(
      ENV.fetch('OWNING_APP'),
      link_types: link_types,
    ).migrate!
  end

  def link_types
    env_link_types = ENV['LINK_TYPES']
    if env_link_types
        env_link_types.split(',').map(&:to_sym)
    else
        TaggingMigrator::LINK_TYPES
    end
  end
end
