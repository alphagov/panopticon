class CreateRelatedContacts < ActiveRecord::Migration
  def change
    create_table :related_contacts do |t|
      t.references :artefact, :contact, :null => false
      t.integer :sort_key, :null => false
    end

    change_table :related_contacts do |t|
      t.index :artefact_id
      t.index :contact_id
      t.index :sort_key
    end
  end
end
