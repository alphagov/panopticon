class FilteredScope
  def initialize(initial_scope, filters)
    @initial_scope = initial_scope
    @filters = filters
  end

  def scope
    scope = initial_scope

    [:section, :specialist_sector].each do |tag_type|
      if filters[tag_type].present?
        scope = scope.with_parent_tag(tag_type, filters[tag_type])
      end
    end

    if filters[:state].present? && Artefact::STATES.include?(filters[:state])
      scope = scope.in_state(filters[:state])
    end

    if filters[:kind].present? && Artefact::FORMATS.include?(filters[:kind])
      scope = scope.of_kind(filters[:kind])
    end

    if filters[:search].present?
      scope = scope.matching_query(filters[:search])
    end

    if filters[:owned_by].present?
      scope = scope.owned_by(filters[:owned_by])
    else
      # Exclude all panopticon-owned artefacts from the index
      # because they have their own specialised interfaces.
      scope = scope.not_owned_by('panopticon')
    end

    scope
  end

private

  attr_reader :initial_scope, :filters
end
