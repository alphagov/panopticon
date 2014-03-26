class CopyArtefactNeedIdToArrayFieldNeedIds < Mongoid::Migration
  def self.up
    artefacts_with_need_id = Artefact.where(:need_id.exists => true, :need_id.nin => ["", nil])
    artefacts_with_need_id.each do |artefact|
      artefact.set(:need_ids, [artefact.need_id])
    end
  end

  def self.down
    Artefact.where(:need_ids.exists => true).update_all(:need_ids => [])
  end
end
