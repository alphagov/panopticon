class RemoveFindLocalCouncilArtefact < Mongoid::Migration
  def self.up
    # Actually fully delete this artefact.
    # It was created in error on launch day and immediately archived without
    # publishing (or even completing the creation of the associated edition
    # in publisher).  We want to reuse the route without leaving something
    # lying around that could accidently be used to alter that route from
    # panopticon.
    Artefact.find_by(slug: 'find-local-council').destroy
  end

  def self.down
  end
end
