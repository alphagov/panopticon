class NormaliseNeedIDs < Mongoid::Migration
  def self.up
    Artefact.where(need_id: "1").update_all(need_id: nil)
  end

  def self.down
  end
end