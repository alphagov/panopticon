class AddContentIdToPublisherDocuments < Mongoid::Migration
  def self.up
    Artefact.where(owning_app: 'publisher', content_id: nil).each do |artefact|
      artefact.set(:content_id, SecureRandom.uuid)
    end
  end

  def self.down
  end
end
