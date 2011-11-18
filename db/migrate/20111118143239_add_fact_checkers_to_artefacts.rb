class AddFactCheckersToArtefacts < ActiveRecord::Migration
  def change
    add_column :artefacts, :fact_checkers, :string
  end
end
