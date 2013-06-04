class UpdateSearchObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    rummageable_artefact = RummageableArtefact.new(artefact)
    
    rummageable_artefact.submit if rummageable_artefact.should_be_indexed?

    if artefact.live? && becoming_nonindexed_kind?(artefact)
      rummageable_artefact.delete
    end

    # Relying on current behaviour where this does not raise errors
    # if done more than once, or done on artefacts never put live
    rummageable_artefact.delete if artefact.archived?
  end

  def becoming_nonindexed_kind?(artefact)
    old_kind = artefact.kind_was
    new_kind = artefact.kind

    not_a_new_record = ! old_kind.nil?
    not_a_new_record &&
        (RummageableArtefact.indexable_artefact?(old_kind, artefact.slug)) &&
         !RummageableArtefact.indexable_artefact?(new_kind, artefact.slug)
  end
end
