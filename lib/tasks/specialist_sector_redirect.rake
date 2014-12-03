require 'gds_api/publishing_api'

desc "Redirect old specialist sectors"
task :specialist_sector_redirect => :environment do
  if ENV['OLD_SLUG'].present? && ENV['NEW_SLUG'].present?
    old_slug = ENV.fetch('OLD_SLUG')
    new_slug = ENV.fetch('NEW_SLUG')
    old_tag = Tag.where(tag_id: old_slug, tag_type: "specialist_sector").first
    new_tag = Tag.where(tag_id: new_slug, tag_type: "specialist_sector").first

    if old_tag && new_tag
      puts "Old and new tags found"
      was_live = old_tag.live?

      # Archiving the artefact will trigger its removal from the search index.
      artefact = Artefact.where(slug: old_slug, kind: "specialist_sector").first
      puts "Archiving artefact \"#{artefact.id}\""
      artefact.state = "archived"
      artefact.save

      puts "Deleting tag \"#{old_tag.tag_id}\""
      old_tag.destroy

      if was_live
        publishing_api = GdsApi::PublishingApi.new(Plek.find("publishing-api"))
        document_for_publishing_api = {
          base_path: "/#{old_slug}",
          format: "redirect",
          publishing_app: "collections-publisher",
          update_type: "major",
          redirects: [
            {"path" => "/#{old_slug}", "type" => "prefix", "destination" => "/#{new_slug}"},
          ]
        }
        publishing_api.put_content_item("/#{old_slug}", document_for_publishing_api)
      else
        puts "This sector had not been published.  Not setting a redirect"
      end
    else
      unless old_tag
        puts "Old sector '#{old_slug}' could not be found"
      end
      unless new_tag
        puts "New sector '#{new_slug}' could not be found"
      end
    end
  else
    puts "Error: old and new slugs were not provided."
    puts "Run this task again, setting the OLD_SLUG and NEW_SLUG environment variables."
    puts "\teg. rake specialist_sector_redirect OLD_SLUG='old-slug' NEW_SLUG='new-slug'"
  end
end
