require 'manual_artefact_guarantor'

namespace :manuals do
  desc "Guarantee that a manual has an artefact"
  task :guarantee_artefact, [] => :environment do |_task, args|
    manual_slugs = args.extras
    if manual_slugs.empty?
      puts "Usage: rake manuals:guarantee_artefact[manual-slug-to-check-1,manual-slug-to-check-2,...,manual-slug-to-check-n]"
    else
      manual_slugs.each do |manual_slug|
        print "Guaranteeing Artefact exists for manual '#{manual_slug}': "
        puts ManualArtefactGuarantor.guarantee(manual_slug)
      end
    end
  end
end
