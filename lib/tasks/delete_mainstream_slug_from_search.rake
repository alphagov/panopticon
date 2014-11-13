desc "Delete a mainstream slug from search"

task :delete_mainstream_slug_from_search, [:slug] => :environment do |_task, args|
  slug = args[:slug]
  raise "Slug must be present!" if slug.blank?
  slug = (slug =~ /^\// ? slug : "/#{slug}")
  SearchIndex.instance.delete(slug)
end
