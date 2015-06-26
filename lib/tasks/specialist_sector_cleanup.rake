desc "Deleting specialist sectors"
task :specialist_sector_cleanup => :environment do
  if ENV['SLUG'].present?
    slug = ENV.fetch('SLUG')
    tag = Tag.where(tag_id: slug, tag_type: "specialist_sector").first

    if tag
      puts "Tag #{slug} found"

      if tag.live?
        puts "WARNING! This sector has been published.  You will need to redirect its URL"
      end

      puts "Deleting tag \"#{tag.tag_id}\""
      tag.destroy
    else
      puts "The sector '#{slug}' could not be found"
    end
  else
    puts "Error: the slug of the sector was not provided."
    puts "Run this task again, setting the SLUG environment variable."
    puts "\teg. rake specialist_sector_cleanup SLUG=\"the-slug\""
  end
end
