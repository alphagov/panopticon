class BulkSectionSetter
  attr_accessor :artefacts

  def initialize(filename, logger = nil)
    @artefacts = load(filename)
    @logger = logger || NullLogger.instance
  end

  def load(filename)
    artefacts = []
    section = nil
    subsection = nil
    File.open(filename, 'r').each do |line|
      if line =~ /^    /
        artefacts << {
          title: line.strip,
          subsection: subsection,
          section: section
        }
      elsif line =~ /^  /
        subsection = line.strip
      else
        section = line.strip
      end
    end
    artefacts
  end

  def set_all
    @artefacts.each do |record|
      artefact = Artefact.find_by_name(record[:title])
      section = "#{record[:section]}:#{record[:subsection]}"
      if artefact
        artefact.section = section
        begin
          artefact.save!
          @logger.info("Set '#{record[:title]}' to set section '#{section}'")
        rescue => e
          @logger.warn("Couldn't save '#{record[:title]}' because '#{e}'")
        end
      else
        @logger.warn("Couldn't find '#{record[:title]}' to set section '#{section}'")
      end
    end
  end
end