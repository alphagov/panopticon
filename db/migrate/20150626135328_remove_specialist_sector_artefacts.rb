class RemoveSpecialistSectorArtefacts < Mongoid::Migration
  def self.up
    search_index = SearchIndex.instance
    Artefact.where(:kind => "specialist_sector").each do |artefact|
      # Remove from search (at the incorrect URL without the /topic prefix)
      search_index.delete("/#{artefact.slug}") if artefact.live?

      artefact.delete
    end
    search_index.commit
  end

  def self.down
  end
end
