class AddContactotronIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contactotron_id, :integer, :null => false
  end
end
