class AddPrefixesToFindYourLocalCouncilTransaction < Mongoid::Migration
  def self.up
    find_your_local_council = Artefact.find_by_slug('find-your-local-council')
    # Remove the exact route for /find-your-local-council...
    find_your_local_council.paths = ['/find-your-local-council.json']
    # ...and add it as a prefix route instead
    find_your_local_council.prefixes = ['/find-your-local-council']
    find_your_local_council.save!
  end

  def self.down
  end
end
