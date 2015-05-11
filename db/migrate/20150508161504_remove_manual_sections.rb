class RemoveManualSections < Mongoid::Migration
  def self.up
    Artefact.where(kind: "manual-section").delete_all
  end

  def self.down
    raise IrreversibleMigration
  end
end
