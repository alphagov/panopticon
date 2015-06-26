class RemoveSpecialistSectorRoutes < Mongoid::Migration
  def self.up
    Artefact.where(:kind => "specialist_sector").each do |artefact|
      artefact.set(:paths, [])
      artefact.set(:prefixes, [])
    end
  end

  def self.down
  end
end
