class IndexSlugs < ActiveRecord::Migration
  def change
    add_index :artefacts, :slug, unique: true
  end
end
