class RemoveManualChangeHistories < Mongoid::Migration
def self.up
    Artefact.where(kind: "manual-change-history").delete_all
  end

  def self.down
    raise IrreversibleMigration
  end
end
