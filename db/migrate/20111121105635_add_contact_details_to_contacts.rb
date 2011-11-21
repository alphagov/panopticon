class AddContactDetailsToContacts < ActiveRecord::Migration
  def change
    change_table :contacts do |t|
      t.text :postal_address
      t.string :email_address
      t.string :website_url
      t.text :opening_hours
    end
  end
end
