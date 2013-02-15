class UpdateTravelAdviceSlugs < Mongoid::Migration
  def self.up
    Artefact.where(:slug => %r{\Atravel-advice/}).each do |artefact|
      if ! Rails.env.development? or ENV['UPDATE_SEARCH'].present?
        Rummageable.delete("/#{artefact.slug}")
      end
      artefact.set(:slug, "foreign-#{artefact.slug}")
    end
  end

  def self.down
    Artefact.where(:slug => %r{\Aforeign-travel-advice/(.*)\z}).each do |artefact|
      artefact.set(:slug, artefact.slug.sub(/\Aforeign-/, ''))
    end
  end
end
