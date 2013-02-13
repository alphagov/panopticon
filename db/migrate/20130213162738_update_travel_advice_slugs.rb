class UpdateTravelAdviceSlugs < Mongoid::Migration
  def self.up
    Artefact.where(:slug => %r{\Atravel-advice/}).each do |artefact|
      artefact.slug = "foreign-#{artefact.slug}"
      artefact.save :validate => false # validate => false necessary because these will be live artefacts
    end
  end

  def self.down
    Artefact.where(:slug => %r{\Aforeign-travel-advice/(.*)\z}).each do |artefact|
      artefact.slug = artefact.slug.sub(/\Aforeign-/, '')
      artefact.save :validate => false # validate => false necessary because these will be live artefacts
    end
  end
end
