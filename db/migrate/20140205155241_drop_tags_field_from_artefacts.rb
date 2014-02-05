class DropTagsFieldFromArtefacts < Mongoid::Migration
  def self.up
    Artefact.collection.update({}, {'$unset' => {tags: 1}}, multi: true)
  end

  def self.down
  end
end
