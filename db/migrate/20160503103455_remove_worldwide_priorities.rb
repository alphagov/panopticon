class RemoveWorldwidePriorities < Mongoid::Migration
  def self.up
    Artefact.where(:kind => 'worldwide_priority').each do |artefact|
      artefact.destroy
    end
  end

  def self.down
  end
end
