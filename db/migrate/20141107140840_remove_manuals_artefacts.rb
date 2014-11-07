class RemoveManualsArtefacts < Mongoid::Migration
  def self.up
    Artefact.where(owning_app: "specialist-publisher", rendering_app: "manuals-frontend").destroy_all
  end

  def self.down
  end
end
