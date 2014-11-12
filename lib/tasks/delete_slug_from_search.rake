desc "Delete mainstream slugs from search.\n
See original documentation @ https://github.com/alphagov/wiki/wiki/Changing-GOV.UK-URLs#making-the-change"

task :delete_mainstream_slug_from_search, [:slug] => :environment do |_task, args|
  raise "Slug must be present!" if args[:slug].blank?
  SearchIndex.instance.delete(args[:slug])
end
