class RemoveSpecialistDocuments < Mongoid::Migration
  def self.up
    Artefact.where({kind: 'specialist-document'}).destroy_all
  end

  def self.down
  end
end
