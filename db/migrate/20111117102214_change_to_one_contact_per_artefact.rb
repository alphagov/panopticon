class ChangeToOneContactPerArtefact < ActiveRecord::Migration
  def up
    change_table :artefacts do |t|
      t.references :contact
    end

    Artefact.reset_column_information
    Artefact.includes(:contacts).each do |artefact|
      if artefact.contacts.present?
        artefact.update_attributes! :contact => artefact.contacts.first
      end
    end

    drop_table :related_contacts
  end

  def down
    create_table :related_contacts do |t|
      t.references :artefact, :contact, :null => false
      t.integer :sort_key, :null => false
    end

    change_table :related_contacts do |t|
      t.index :artefact_id
      t.index :contact_id
      t.index :sort_key
    end

    RelatedContact.reset_column_information
    Artefact.includes(:contact).each do |artefact|
      if artefact.contact.present?
        artefact.related_contacts.create! :contact => artefact.contact, :sort_key => 0
      end
    end

    change_table :artefacts do |t|
      t.remove_references :contact
    end
  end
end

class Artefact < ActiveRecord::Base
  # before
  has_many :related_contacts, :order => 'sort_key ASC'
  has_many :contacts, :through => :related_contacts

  # after
  belongs_to :contact
end

class RelatedContact < ActiveRecord::Base
  # before
  belongs_to :artefact
  belongs_to :contact
end
