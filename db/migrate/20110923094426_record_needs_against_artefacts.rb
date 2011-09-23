class RecordNeedsAgainstArtefacts < ActiveRecord::Migration
  def up
    add_column :artefacts, :need_id, :integer
    add_index :artefacts, :need_id
  end

  def down
    remove_index :artefacts, :need_id
    remove_column :artefacts, :need_id
  end
end
