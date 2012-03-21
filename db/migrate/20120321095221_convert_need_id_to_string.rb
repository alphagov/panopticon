class ConvertNeedIdToString < ActiveRecord::Migration
  def up
  	change_column :artefacts, :need_id, :string
  end

  def down
  	change_column :artefacts, :need_id, :integer
  end
end
