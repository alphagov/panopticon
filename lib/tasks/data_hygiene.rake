namespace :data_hygiene do
  task :verify_formats => [:environment] do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP.detect do |app_name, formats|
      mislabeled = Artefact.where(owning_app: app_name, :kind.nin => formats)

      puts "\n#{app_name}:"
      puts "#{mislabeled.size} docs with foreign formats: #{mislabeled.map(&:kind).uniq.inspect}"
    end
  end
end
