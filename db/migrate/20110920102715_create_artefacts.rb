class CreateArtefacts < ActiveRecord::Migration
  def up
    create_table :artefacts do |t|
      t.string :slug, :null => false
      # FIXME: kind makes owning app redundant.
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

      t.boolean :active, :null => false, :default => false

      t.timestamps
    end
  end

  def down
  end
end
