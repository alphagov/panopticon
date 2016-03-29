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
  attr_accessor :skip_update_search

  # Upon archiving an artefact we want this callback to run to remove
  # any related items that also point to that artefact.
  after_save :remove_related_artefacts
  # When saving an artefact we want to send it to the router.
  after_save :update_router
  # When saving an artefact we want to update search.
  after_save :update_search

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

  def update_router
    RoutableArtefact.new(self).submit
  end

  def update_search
    return if skip_update_search
    rummageable_artefact = RummageableArtefact.new(self)

    rummageable_artefact.submit if rummageable_artefact.should_be_indexed?

    if live? && becoming_nonindexed_kind?
      rummageable_artefact.delete
    end

    # Relying on current behaviour where this does not raise errors
    # if done more than once, or done on artefacts never put live
    rummageable_artefact.delete if archived?
  end

  def remove_related_artefacts
    if archived?
      Artefact.where(:related_artefact_ids.in => [id]).each do | a |
        a.related_artefact_ids.delete(id)
        a.save
      end
    end
  end

  def app_without_tagging_support?
    APPS_WITHOUT_TAGGING_SUPPORT.include?(self.owning_app)
  end

private

  def new_record_without_owning_app?
    self.new_record? && self.owning_app.nil?
  end

  def becoming_nonindexed_kind?
    old_kind = kind_was
    new_kind = kind

    not_a_new_record = ! old_kind.nil?
    not_a_new_record &&
        (RummageableArtefact.indexable_artefact?(old_kind, slug)) &&
         !RummageableArtefact.indexable_artefact?(new_kind, slug)
  end
end
