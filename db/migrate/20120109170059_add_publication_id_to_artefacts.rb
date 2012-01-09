class AddPublicationIdToArtefacts < ActiveRecord::Migration
  def change
    add_column :artefacts, :publication_id, :string
  end
end
