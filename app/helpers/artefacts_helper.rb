module ArtefactsHelper
  def related_items_for(artefact)
    (0...Artefact::MAXIMUM_RELATED_ITEMS).
      map { |sort_key| related_item_with_sort_key(artefact.related_items, sort_key) }
  end

  private
    def related_item_with_sort_key(related_items, sort_key)
      related_items.detect { |related_item| related_item.sort_key == sort_key } ||
        RelatedItem.new(:sort_key => sort_key)
    end
end
