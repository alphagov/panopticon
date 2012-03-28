class AddBusinessPropositionToArtefact < ActiveRecord::Migration
  def change
    add_column :artefacts, :business_proposition, :boolean, :default => false
  end
end
