class RemoveRelatednessDone < Mongoid::Migration
  def self.up
    Artefact.all.each do |artefact|
      artefact.unset(:relatedness_done)
    end
  end

  def self.down
  end
end