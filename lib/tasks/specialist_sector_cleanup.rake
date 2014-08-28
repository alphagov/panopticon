desc "Deleting specialist sectors"
task :specialist_sector_cleanup => :environment do
  puts "Which specialist sector is being deleted?"
  slug = STDIN.gets.chomp

  tag = Tag.where(tag_id: slug, tag_type: "specialist_sector").first

  if tag
    puts "Tag #{slug} found"

    if tag.live?
      puts "WARNING! This sector has been published.  You will need to redirect its URL"; puts
    end

    puts "What would you like to do?"
    puts "1. Delete the tag, removing it from the search index"
    puts "2. Do nothing [default]"

    case STDIN.gets.chomp
    when "1"
      # Archiving the artefact will trigger its removal from the search index.
      artefact = Artefact.where(slug: slug, kind: "specialist_sector").first
      puts "Archiving artefact"
      artefact.state = "archived"
      artefact.save

      puts "Deleting tag"
      tag.destroy
    when "2", ""
      puts "Doing nothing"
      exit
    else
      puts "Invalid option"
      exit
    end
  else
    puts "The sector '#{slug}' could not be found"
  end
end
