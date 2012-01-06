class AddRelatednessDoneFlag < ActiveRecord::Migration
  def up
    add_column :artefacts, :relatedness_done, :boolean, :default => false
  end

  def down
    remove_column :artefacts, :relatedness_done
  end
end
