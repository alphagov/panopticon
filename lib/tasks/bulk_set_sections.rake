namespace :sections do

  desc "Set sections in bulk (specify DOCUMENT_SECTIONS_FILE)"
  task :bulk_set => :environment do
    raise "Specify DOCUMENT_SECTIONS_FILE" unless ENV['DOCUMENT_SECTIONS_FILE']
    raise "DOCUMENT_SECTIONS_FILE '#{ENV['DOCUMENT_SECTIONS_FILE']} not found" unless File.exist?(ENV['DOCUMENT_SECTIONS_FILE'])

    require 'bulk_section_setter'
    s = BulkSectionSetter.new(ENV['DOCUMENT_SECTIONS_FILE'], Logger.new(STDOUT))
    s.set_all
  end
end