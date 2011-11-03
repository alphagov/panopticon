module ArtefactsHelper
  def related_items_for(artefact)
    (0...Artefact::MAXIMUM_RELATED_ITEMS).
      map { |sort_key| associated_record_with_sort_key(artefact.related_items, sort_key) }
  end

  def related_contacts_for(artefact)
    (0...Artefact::MAXIMUM_RELATED_CONTACTS).
      map { |sort_key| associated_record_with_sort_key(artefact.related_contacts, sort_key) }
  end

  private
    def associated_record_with_sort_key(association, sort_key)
      association.detect { |record| record.sort_key == sort_key } || association.new(:sort_key => sort_key)
    end
end
