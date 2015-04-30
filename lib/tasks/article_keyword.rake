require 'csv'

namespace :article_keyword do
  desc "Export Articles and their Keywords into a CSV for easy editing."
  task :export => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Exporting articles..."

    count = 0
    number_of_editions_without_tags = 0

    CSV.open("data/article_keywords.csv", "wb") do |csv|
      csv << ["artefact_id", "type", "slug", "artefact_name", "keyword_1", "keyword_2", "etc"]

      Artefact.all.each_with_index do |artefact, index|
        begin
          count += 1
          puts artefact.kind
          keywords = artefact.tags.select do |tag|
            tag.tag_type == 'keyword'
          end
          if keywords.count == 0
            csv << [artefact.id, artefact.kind, artefact.slug, artefact.name]
            number_of_editions_without_tags += 1
          end
        end
      end
    end

    logger.info "Found #{number_of_editions_without_tags} editions without keywords."
  end
end
