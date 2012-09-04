namespace :reports do
  desc "Generate CSV file of all live artefacts"
  task live_artefacts: :environment do
    unless ENV['filename']
      puts "Please specify an output filename, eg: rake reports:live_artefacts filename=blah.csv"
      exit(1)
    end

    column_headings = [:name, :format, :url, :sections]

    require 'csv'

    puts "Generating CSV"

    CSV.open(ENV['filename'], 'w') do |csv|
      csv << column_headings.collect { |ch| ch.to_s.humanize }
      Artefact.where(state: 'live').each do |a|
        row = [
          a.name,
          a.kind,
          "https://www.gov.uk/#{a.slug}"
        ]
        row += a.sections.collect { |t| t.unique_title }
        csv << row
        print "."
      end
    end
    puts
  end
end