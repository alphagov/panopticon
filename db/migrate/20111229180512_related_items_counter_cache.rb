class RelatedItemsCounterCache < ActiveRecord::Migration
  def up
    add_column :artefacts, :related_items_count, :integer, :default => 0
    Artefact.reset_column_information
    Artefact.find_each do |a|
      Artefact.update_counters a.id, :related_items_count => a.related_items.count
    end
    add_index :artefacts, :name
  end

  def down
  end
end
