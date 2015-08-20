class DeleteSpecialistDocuments < Mongoid::Migration
  def self.up
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["specialist-publisher"].each do |kind|
      Artefact.where(kind: kind).each do |artefact|
        puts "Destroying artefact ##{artefact.id}"
        artefact.destroy
        Edition.where(panopticon_id: artefact.id).each do |edition|
          puts "Destroying edition ##{edition.id} for artefact ##{artefact.id}"
          edition.destroy
        end
      end
    end
  end

  RenderedManual.all.each(&:destroy)
  RenderedSpecialistDocument.all.each(&:destroy)
end
