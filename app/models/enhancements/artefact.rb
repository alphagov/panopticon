require "artefact"

class Artefact
  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content, :paths, :prefixes, :rendering_app
end
