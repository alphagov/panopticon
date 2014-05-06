class FixNilNeedIdsOnArtefacts < Mongoid::Migration
  def self.up
    result = Artefact.where(need_ids: nil).update_all(need_ids: [])
    puts "Updated need_ids to `[]` for #{result["n"]} artefacts where need_ids was nil"
  end

  def self.down
  end
end
