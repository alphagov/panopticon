task :import => :environment do
  class SlugGenerator
    attr_accessor :text
    private :text=, :text

    def initialize text
      self.text = text
    end

    def execute
      result = text.dup
      result.strip!
      result.gsub! /[^a-zA-Z0-9]+/, '-'
      result.gsub! /\s+/, '-'
      result.gsub! /^-+|-+$/, ''
      result.downcase!
      result
    end
  end

  class LegacyRelatedItemField
    attr_accessor :raw_text
    private :raw_text=, :raw_text

    def initialize raw_text
      self.raw_text = raw_text
    end

    def doc
      Nokogiri::XML "<root>#{raw_text}</root>"
    end

    def create_artefact name, publication_type, slug = nil
      artefact = Artefact.new
      artefact.name = name
      artefact.slug = slug || SlugGenerator.new(name).execute
      artefact.kind = publication_type.to_s.strip.downcase
      artefact.owning_app = 'publisher' # We only have one app at the moment
      artefact.tags = ""
      artefact.save
      if artefact.errors.any?
        puts artefact.errors.full_messages.to_sentence
      end
      artefact
    end

    def each
      items = doc.xpath "//root/li"
      puts "          - found #{items.to_a.size} related items"
      items.to_a.each_with_index do |li, index|
        publication_type = li['class'].to_s.strip.downcase
        slug = li.css("a").to_a[0]['href'].to_s.strip
        name = li.css("a").to_a[0].text.to_s.strip

        if slug == '#' || slug.blank?
          artefact = Artefact.find_by_name name
          if artefact.present?
            slug = artefact.slug
            puts "          - mapping empty slug for #{name} to #{slug}"
          else
            puts "          - creating #{name} since slug is blank and I can't find an Artefact with that name"
            artefact = create_artefact name, publication_type
            slug = artefact.slug
          end
        end
        item = OpenStruct.new :publication_type => publication_type,
          :slug => slug, :name => name, :index => index
        def item.artefact
          Artefact.find_by_slug slug
        end
        puts "          - processing #{item.slug} (#{item.name})"

        yield item
      end
    end

    def migrate_to artefact
      if raw_text.to_s.strip.blank?
        puts "          - no related items"
      end

      each do |item|
        related = item.artefact
        unless related.present?
          related = create_artefact item.name, item.publication_type, item.slug
          next if related.new_record?
          puts "          - created #{item.slug} for #{item.name}"
        end
        puts "          - #{item.index} => #{related.slug}"
        RelatedItem.create! :source_artefact => artefact, :artefact => related, :sort_key => item.index
      end
    end
  end

  class ArtefactImporter
    attr_accessor :identifier
    private :identifier=, :identifier

    def initialize identifier
      self.identifier = identifier
    end

    def execute
      artefact = Artefact.find_by_slug identifier.slug
      artefact ||= Artefact.new
      artefact.name = publication['title']
      artefact.slug = identifier.slug
      artefact.kind = identifier.kind.to_s.downcase.strip
      artefact.owning_app = identifier.owning_app
      artefact.active = identifier.active
      artefact.tags = publication['tags']
      artefact.save!

      publication['audiences'].to_a.each do |audience_name|
        next if audience_name.to_s.strip.blank?
        audience = Audience.find_by_name audience_name
        unless audience.present?
          puts "          - I had to create audience '#{audience_name}'"
          audience = Audience.create! :name => audience_name
        end
        artefact.audiences << audience
      end

      true
    rescue OpenURI::HTTPError
      print "publisher couldn't find this slug"
      false
    rescue URI::InvalidURIError
      print "invalid slug"
      false
    rescue => e
      puts "        " + [e.class, e.message, e.backtrace].join("\n        ")
      false
    end

    def publication
      Publication.new(identifier.slug).to_json
    end
  end

  class Publication
    attr_accessor :slug
    private :slug=, :slug

    def initialize slug
      self.slug = slug
    end

    def to_json
      record = open Plek.current.find("publisher") + '/publications/' + slug + '.json?edition=latest'
      data = record.read
      JSON.parse data
    end
  end

  class RelatedItemImporter
    attr_accessor :artefact
    private :artefact=, :artefact

    def initialize artefact
      self.artefact = artefact
    end

    def publication
      Publication.new(artefact.slug).to_json
    end

    def execute
      items = LegacyRelatedItemField.new(publication['related_items'])
      items.migrate_to artefact
    rescue OpenURI::HTTPError
      print "publisher couldn't find this slug"
    rescue URI::InvalidURIError
      print "invalid slug"
    rescue => e
      puts "        " + [e.class, e.message, e.backtrace].join("\n        ")
    end
  end

  Bundler.require :import
  require 'open-uri'

  Artefact.all(order: 'slug asc').each do |artefact|
    puts "      * #{artefact.slug}..."
    success = RelatedItemImporter.new(artefact).execute
  end
end
