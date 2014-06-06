class Artefact
  module FilterScopes
    extend ActiveSupport::Concern

    included do

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

    end
  end
end
