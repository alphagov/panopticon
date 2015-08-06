namespace :detailed_guide do
  desc "Reslugs Detailed Guide artefacts to live under /guidance"
  task reslug: :environment do
    scope = Artefact.where(kind: 'detailed_guide')
    count = scope.count

    scope.each_with_index do |detailed_guide, i|
      unless detailed_guide.slug.start_with?('guidance/')
        old_slug = detailed_guide.slug
        new_slug = "guidance/#{old_slug}"

        begin
          path = Rails.application.url_arbiter_api.reserve_path("/#{new_slug}",
            "publishing_app" => "whitehall")
          detailed_guide.set(:slug, new_slug)
          puts "Renamed #{old_slug} to #{new_slug} (#{i+1}/#{count})"
        rescue GOVUK::Client::Errors::Conflict => e
          puts "Couldn't rename #{old_slug} to #{new_slug} (#{i+1}/#{count})"
          message = ""
          if e.response["errors"]
            e.response["errors"].each do |field, errors|
              errors.each do |error|
                message << "#{field.humanize} #{error}\n"
              end
            end
          else
            message = e.response.raw_body
          end
          puts message
        end
      end
    end
  end
end
