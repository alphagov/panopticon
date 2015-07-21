class ReregisterArchivedWhitehallArtefactRoutes < Mongoid::Migration
  def self.up
    Artefact.where(:state => 'archived', :owning_app => 'whitehall').each do |artefact|
      # register the routes with the router.
      RoutableArtefact.new(artefact).register
    end
    RoutableArtefact.new(nil).commit
  end

  def self.down
  end
end
