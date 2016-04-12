require "artefact"
require_relative "artefact/filter_scopes"

class Artefact
  include Artefact::FilterScopes

  NON_MIGRATED_APPS = %w(
    publisher
    specialist-publisher
    whitehall
    non-migrated-app
  ).freeze

  APPS_WITHOUT_TAGGING_SUPPORT = %w(
    finder-api
    frontend
    planner
  ).freeze

  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  STATES = [ "live", "draft", "archived" ]

  scope :relatable_items_like, proc { |title_substring|
    relatable_items
      .any_of(:name => /\A#{Regexp.escape(title_substring)}/i)
  }

  def related_artefact_slugs=(slugs)
    related_artefacts = Artefact.relatable_items.where(:slug.in => slugs).only(:_id, :slug).to_a
    # mongo doesn't guarantee the order of elements returned in response to `$in` query
    self.related_artefact_ids = related_artefacts.sort_by { |a| slugs.index(a.slug) }.map(&:_id)
  end

  def related_artefact_slugs
    ordered_related_artefacts(related_artefacts.only(&:slug)).map(&:slug)
  end

  def name_with_owner_prefix
    (owning_app == "whitehall" ? "[Whitehall] " : "[Mainstream] ") + name
  end

  def allow_specialist_sector_tag_changes?
    owning_app != 'publisher' && owning_app != 'whitehall'
  end

  def allow_section_tag_changes?
    owning_app != 'publisher'
  end

  def tagging_migrated?
    return false if new_record_without_owning_app?

    !NON_MIGRATED_APPS.include?(self.owning_app)
  end

  def app_without_tagging_support?
    APPS_WITHOUT_TAGGING_SUPPORT.include?(self.owning_app)
  end

  private

  def new_record_without_owning_app?
    self.new_record? && self.owning_app.nil?
  end
end
