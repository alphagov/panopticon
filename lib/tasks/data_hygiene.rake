namespace :data_hygiene do
  desc "Verify that artefacts have the correct `owning_app`"
  task verify_formats: [:environment] do
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP.detect do |app_name, formats|
      mislabeled = Artefact.where(owning_app: app_name, :kind.nin => formats)

      puts "\n#{app_name}:"
      puts "#{mislabeled.size} docs with foreign formats: #{mislabeled.map(&:kind).uniq.inspect}"
    end
  end

  desc "See which artefacts don't have content IDs"
  task inspect_content_ids: [:environment] do
    owning_apps = Artefact.all.distinct("owning_app")
    owning_apps.each do |owning_app|
      without_content_id = Artefact.where(content_id: nil, owning_app: owning_app).count
      with_content_id = Artefact.where(owning_app: owning_app).count - without_content_id

      puts "#{owning_app}: #{without_content_id} without, #{with_content_id} with"
    end
  end

  desc "Produce a CSV of artefacts with tags of a given type"
  task list_tagged_artefacts: [:environment] do
    csv_out = CSV.new($stdout)
    csv_out << %w(content_id tag_type count)
    buffer = []

    artefacts = Artefact.where(owning_app: OwningApp::WHITEHALL, state: "live", :tags.ne => [], :content_id.ne => nil)

    artefacts.each do |artefact|
      tag_type_counts = artefact.tags
        .group_by(&:tag_type)
        .map { |tag_type, tags| [tag_type, tags.size] }
        .sort_by(&:first)

      tag_type_counts.each do |tag_type, count|
        link_type = tag_to_link[tag_type] || tag_type
        buffer << [artefact.content_id, link_type, count]
      end
    end

    # Sort in memory because mongodb refuses to do so without an index
    buffer.sort!

    buffer.each do |row|
      csv_out << row
    end
  end

  def tag_to_link
    @tag_to_link ||= TaggingUpdater::TAG_MAPPING.map { |k, v| [v, k] }.to_h
  end
end
