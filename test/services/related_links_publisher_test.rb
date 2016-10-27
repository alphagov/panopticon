require "test_helper"
require 'gds_api/test_helpers/publishing_api'

class RelatedLinksPublisherTest < ActiveSupport::TestCase
  def test_it_sends_related_links_properly
    artefact = FactoryGirl.create(:artefact, content_id: "e0c8d0bf-823d-4466-9c81-8587d3318746")
    FactoryGirl.create(:artefact, slug: "the-second-one", content_id: "d156631f-ef51-44b8-a0ef-0a7220b0e4fe")
    FactoryGirl.create(:artefact, slug: "the-first-one", content_id: "72a369e2-4146-4ef2-aeee-7042a25f2a33")

    artefact.related_artefact_slugs = ["the-first-one", "the-second-one"]
    artefact.save!

    request = stub_request(:patch, "http://publishing-api.dev.gov.uk/v2/links/e0c8d0bf-823d-4466-9c81-8587d3318746").
      with(:body => { links: { ordered_related_items: ["72a369e2-4146-4ef2-aeee-7042a25f2a33", "d156631f-ef51-44b8-a0ef-0a7220b0e4fe" ] } }.to_json).
        to_return(body: {}.to_json)

    RelatedLinksPublisher.new(artefact).publish!

    assert_requested(request)
  end
end
