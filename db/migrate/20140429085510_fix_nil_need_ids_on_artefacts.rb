class FixNilNeedIdsOnArtefacts < Mongoid::Migration
  def self.up
    Artefact.collection.find_and_modify(query: {need_ids: nil}, update: {need_ids: []})
  end

  def self.down
  end
end
