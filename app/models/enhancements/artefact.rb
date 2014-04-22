require "artefact"
require_relative "artefact/filter_scopes"

class Artefact
  include Artefact::FilterScopes

  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  STATES = [ "live", "draft", "archived" ]

end
