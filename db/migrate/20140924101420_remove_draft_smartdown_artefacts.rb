class RemoveDraftSmartdownArtefacts < Mongoid::Migration
  def self.up
    draft_slugs = %w(animal-example-simple animal-example-multiple employee-parental-leave student-finance-forms-transition)
    draft_slugs.each do |slug|
      artefact = Artefact.find_by_slug(slug)
      if artefact
        RummageableArtefact.new(artefact).delete
        puts "Successfully deleted #{slug}" if artefact.destroy
      end
    end
  end

  def self.down
  end
end
