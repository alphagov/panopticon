class MoveDetailedGuidesSlugsUnderGuidance < Mongoid::Migration
  def self.up
    Artefact.where(kind: 'detailed_guide').each do |detailed_guide|
      unless detailed_guide.slug.start_with?('guidance/')
        old_slug = detailed_guide.slug
        new_slug = "guidance/#{old_slug}"
        begin
          path = Rails.application.url_arbiter_api.reserve_path("/#{new_slug}", "publishing_app" => "whitehall")
          detailed_guide.slug = new_slug
          detailed_guide.save!
          puts "moved #{old_slug} to #{new_slug}"
        rescue GOVUK::Client::Errors::Conflict => e
          puts "couldn't move #{old_slug} to #{new_slug}"
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

  def self.down
  end
end
