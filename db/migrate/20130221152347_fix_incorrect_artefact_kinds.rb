class FixIncorrectArtefactKinds < Mongoid::Migration
  def self.up
    Artefact.where(state: "live", owning_app: "publisher").each do |artefact|
      edition = Edition.published.where(panopticon_id: artefact.id).first
      if edition
        if artefact.kind != edition.format.underscore
          artefact.kind = edition.format.underscore
          artefact.save
        end
      end
    end
  end

  def self.down
  end
end