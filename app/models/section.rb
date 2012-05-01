class Section

  def initialize(top_level, name)
    @top_level = top_level
    @name      = name
  end

  def slug
    [@top_level, @name].join(":")
  end

  def to_s
    [@top_level, @name].join(" > ")
  end

  class << self
    def all
      @sections ||= load_sections
    end

  private
    def load_sections
      top_level = nil
      File.open(File.expand_path("../sections.txt", __FILE__)).inject([]) { |sections, line|
        if line =~ /^  /
          raise "Bad section.txt, must start with a section (no spaces at start of first line)" if top_level.nil?
          sections << new(top_level, line.strip)
        else
          top_level = line.strip
          sections
        end
      }
    end
  end
end
