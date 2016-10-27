class RelatedLinksPublisher
  attr_reader :artefact

  def initialize(artefact)
    @artefact = artefact
  end

  def publish!
    Rails.application.publishing_api_v2.patch_links(
      artefact.content_id,
      links: {
        ordered_related_items: artefact.ordered_related_artefacts.map(&:content_id).compact
      }
    )
  end
end
