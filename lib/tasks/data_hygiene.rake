namespace :data_hygiene do
  desc "Verify that artefacts have the correct `owning_app`"
  task :verify_formats => [:environment] do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP.detect do |app_name, formats|
      mislabeled = Artefact.where(owning_app: app_name, :kind.nin => formats)

      puts "\n#{app_name}:"
      puts "#{mislabeled.size} docs with foreign formats: #{mislabeled.map(&:kind).uniq.inspect}"
    end
  end

  desc "See which artefacts don't have content IDs"
  task :inspect_content_ids => [:environment] do
    owning_apps = Artefact.all.distinct("owning_app")
    owning_apps.each do |owning_app|
      without_content_id = Artefact.where(content_id: nil, owning_app: owning_app).count
      with_content_id = Artefact.where(owning_app: owning_app).count - without_content_id

      puts "#{owning_app}: #{without_content_id} without, #{with_content_id} with"
    end
  end
end
