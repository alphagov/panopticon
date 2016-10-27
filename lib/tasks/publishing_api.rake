namespace :publishing_api do
  desc "Send all related items to the publishing-api again"
  task republish_related_links: [:environment] do
    artefacts = Artefact.where(
      # Whitehall artefacts can't have related artefacts (the form is hidden).
      :owning_app.nin => [OwningApp::WHITEHALL],

      # Artefacts without content_id are so old that they're not in the
      # publishing-api and don't need to be.
      :content_id.nin => [nil]
    )

    artefacts.each do |artefact|
      print "."
      RelatedLinksPublisher.new(artefact).publish!
    end
  end
end
