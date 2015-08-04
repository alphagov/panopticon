class RemoveDeletedFromArchivedArtefactSlugs < Mongoid::Migration
  def self.up
  	Artefact.where(:state => 'archived', :owning_app => 'whitehall', :slug => /^deleted-/).each do |artefact|
      # register the routes with the router.
      artefact.set(:slug, artefact.slug.gsub("deleted-", ""))
    end
  end

  def self.down
  end
end