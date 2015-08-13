class RemoveFinderArtefacts < Mongoid::Migration
  def self.up
    Artefact.where(:kind => 'finder').each do |artefact|
      artefact.destroy
    end
  end

  def self.down
  end
end
