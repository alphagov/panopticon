require "artefact"

class Artefact
  alias_method :as_json_original, :as_json

  # Upon archiving an artefact we want this callback to run to remove
  # any related items that also point to that artefact.
  after_save :remove_related_artefacts
  # When saving an artefact we want to send it to the router.
  after_save :update_router

  STATES = [ "live", "draft", "archived" ]

  scope :relatable_items_like, proc { |title_substring|
    relatable_items
      .any_of(:name => /\A#{Regexp.escape(title_substring)}/i)
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
    (owning_app == OwningApp::WHITEHALL ? "[Whitehall] " : "[Mainstream] ") + name
  end

  def update_router
    RoutableArtefact.new(self).submit
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
end
