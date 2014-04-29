require "artefact"
require_relative "artefact/filter_scopes"

class Artefact
  include Artefact::FilterScopes

  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  STATES = [ "live", "draft", "archived" ]

  scope :relatable_items_like, proc { |title_substring|
    relatable_items
      .any_of(:name => /#{Regexp.escape(title_substring)}/i)
  }

  def related_artefact_slugs=(slugs)
    related_artefacts = Artefact.relatable_items.where(:slug.in => slugs).only(:_id)
    self.related_artefact_ids = related_artefacts.map(&:_id).to_a
  end

  def related_artefact_slugs
    self.related_artefacts.only(&:slug).map(&:slug)
  end

end
