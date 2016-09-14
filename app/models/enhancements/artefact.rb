require "artefact"

class Artefact
  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content
  attr_accessor :skip_update_search

  alias_method :as_json_original, :as_json

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

  scope :with_tags, proc {|tag_ids|
    # the all_of method is used here so that, if this scope is called multiple
    # times, the query will perform an intersection where artefacts match at least
    # one tag in each list of IDs.
    all_of(:tag_ids.in => tag_ids)
  }
  scope :with_parent_tag, proc {|tag_type, parent_tag_id|
    tags = Tag.where(tag_type: tag_type, parent_id: parent_tag_id)
    with_tags( [ parent_tag_id ] + tags.collect(&:tag_id) )
  }

  scope :of_kind, proc {|kind| where(kind: kind) }
  scope :in_state, proc {|state| where(state: state) }
  scope :owned_by, proc {|owning_app| where(owning_app: owning_app) }
  scope :not_owned_by, proc {|owning_app| where(:owning_app.ne => owning_app) }

  scope :matching_query, proc {|query|
    search = /#{Regexp.escape(query)}/i
    any_of({name: search}, {description: search}, {slug: search}, {kind: search}, {owning_app: search})
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

  def as_json(options={})
    as_json_original(options).tap { |hash|
      hash["id"] = hash["id"].to_s
    }
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
