require "artefact"

class Artefact
  alias_method :as_json_original, :as_json

  STATES = [ "live", "draft", "archived" ]

  scope :of_kind, proc {|kind| where(kind: kind) }
  scope :in_state, proc {|state| where(state: state) }
  scope :owned_by, proc {|owning_app| where(owning_app: owning_app) }
  scope :not_owned_by, proc {|owning_app| where(:owning_app.ne => owning_app) }

  scope :matching_query, proc {|query|
    search = /#{Regexp.escape(query)}/i
    any_of({name: search}, {description: search}, {slug: search}, {kind: search}, {owning_app: search})
  }

  def name_with_owner_prefix
    (owning_app == OwningApp::WHITEHALL ? "[Whitehall] " : "[Mainstream] ") + name
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
