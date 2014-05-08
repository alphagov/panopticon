class FixNilNeedIdsOnArtefacts < Mongoid::Migration
  def self.up
    Artefact.where(need_ids: nil).update_all(need_ids: [])
  end

  def self.down
  end
end
