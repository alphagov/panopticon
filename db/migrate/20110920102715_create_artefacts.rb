class CreateArtefacts < ActiveRecord::Migration
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
      artefact.save!
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
      artefact = Artefact.new
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
      record = open Plek.current.publisher + '/publications/' + slug + '.json?edition=latest'
      data = record.read
      json = JSON.parse data
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
    end
  end

  def up
    Bundler.require :import
    require 'open-uri'

    create_table :related_items do |t|
      t.integer :source_artefact_id, :null => false
      t.integer :artefact_id, :null => false
      t.integer :sort_key, :null => false
    end
    add_index :related_items, :source_artefact_id
    add_index :related_items, :artefact_id
    add_index :related_items, :sort_key

    create_table :audiences do |t|
      t.string :name, :null => false
      t.timestamps
    end

    say "Creating audience list"
    [
      "Age-related audiences",
      "Carers",
      "Civil partnerships",
      "Crime and justice-related audiences",
      "Disabled people",
      "Employment-related audiences",
      "Family-related audiences",
      "Graduates",
      "Gypsies and travellers",
      "Horse owners",
      "Intermediaries",
      "International audiences",
      "Long-term sick",
      "Members of the Armed Forces",
      "Nationality-related audiences",
      "Older people",
      "Partners of people claiming benefits",
      "Partners of students",
      "People of working age",
      "People on a low income",
      "Personal representatives (for a deceased person)",
      "Property-related audiences",
      "Road users",
      "Same-sex couples",
      "Single people",
      "Smallholders",
      "Students",
      "Terminally ill",
      "Trustees",
      "Veterans",
      "Visitors to the UK",
      "Volunteers",
      "Widowers",
      "Widows",
      "Young people"
    ].each do |name|
      say "Creating audience: #{name}", true
      Audience.create! :name => name
    end

    create_table :artefacts_audiences, :id => false do |t|
      t.integer :artefact_id, :null => false
      t.integer :audience_id, :null => false
    end
    add_index :artefacts_audiences, :artefact_id
    add_index :artefacts_audiences, :audience_id

    create_table :artefacts do |t|
      t.string :section
      t.string :name, :null => false
      t.string :slug, :null => false
      # FIXME: kind basically makes owning app redundant (unless I guess there
      #        are two apps that can manage a kind)
      # TODO: Link kind_id -> kinds.id, kinds.tool_id -> tools.id
      # FIXME: kind should be called format for consistency.
      # TODO: Record tools.base_url so we can punt requests off to them easily
      # TODO: Expose that via Panopticon API using Plek
      # TODO: Find some way that each tool can be told to edit or create a new
      #       artefact. Possibly that's exposing a known interface, or maybe
      #       we just handle it using adapters in this app?
      # TODO: Find some way for apps to register their being able to create
      #       formats
      # TODO: Decide what happens when there's a conflict - two or more apps
      #       claim a format
      t.string :kind, :null => false
      t.string :owning_app, :null => false

      # FIXME: This should probably be a state column so we can record if an
      #        artefact has been removed, published, being drafted, replaced, etc.
      t.boolean :active, :null => false, :default => false

      # FIXME: Tags should probably be their own first-order object
      t.string :tags

      t.timestamps
    end

    say_with_time "Migrating Identifiers to Artefacts" do
      Identifier.all(order: 'slug asc').each do |identifier|
        print "      * #{identifier.slug}... "
        success = ArtefactImporter.new(identifier).execute
        puts success ? ' -> ok' : ' -> failed'
      end
    end

    say_with_time "Importing related items" do
      Artefact.all(order: 'slug asc').each do |artefact|
        puts "      * #{artefact.slug}..."
        success = RelatedItemImporter.new(artefact).execute
      end
    end
  end

  def down
  end
end
