class DropIdentifiers < ActiveRecord::Migration
  def up
    drop_table :identifiers
  end

  def down
    create_table :identifiers, :force => true do |t|
      t.boolean  :active,                    :default => false, :null => false
      t.string   :slug,        :limit => 63,                    :null => false
      t.string   :owning_app,  :limit => 50,                    :null => false
      t.string   :kind,        :limit => 50,                    :null => false
      t.datetime :created_at
    end

    add_index :identifiers, :slug, :name => 'unique_identifiers_slug', :unique => true
  end
end
