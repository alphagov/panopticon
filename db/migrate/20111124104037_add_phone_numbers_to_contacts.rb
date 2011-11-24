class AddPhoneNumbersToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :phone_numbers, :text
  end
end
