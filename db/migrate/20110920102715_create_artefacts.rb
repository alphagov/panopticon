class CreateArtefacts < ActiveRecord::Migration
  def up
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
  end

  def down
  end
end
