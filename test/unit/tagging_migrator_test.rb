require_relative "../test_helper"

class TaggingMigratorTest < ActiveSupport::TestCase
  test "sends current migrations to publishing-api" do
    create(:live_tag, tag_id: "a-topic", tag_type: "specialist_sector", content_id: "A-TOPIC")
    create(:live_tag, tag_id: "a-browse-page", tag_type: "section", content_id: "A-BROWSE-PAGE")
    create(:live_tag, tag_id: "an-organisation", tag_type: "organisation", content_id: "AN-ORGANISATION")

    create(:artefact,
      content_id: "A",
      slug: "item-a",
      owning_app: "smartanswers",
      sections: ["a-browse-page"],
      specialist_sectors: ["a-topic"],
    )
    create(:artefact,
      content_id: "B",
      slug: "item-b",
      owning_app: "smartanswers",
      sections: ["a-browse-page"],
      organisations: ["an-organisation"],
    )
    create(:artefact,
      content_id: "C",
      slug: "item-c",
      owning_app: "smartanswers",
    )
    create(:artefact,
      content_id: "D",
      slug: "item-d",
      owning_app: "whitehall",
    )

    stub_request(:put, %r[#{Plek.find('publishing-api')}/v2/links/*]).
      to_return(body: {}.to_json)

    TaggingMigrator.new("smartanswers").migrate!

    assert_requested :put, "http://publishing-api.dev.gov.uk/v2/links/A",
      body: '{"links":{"mainstream_browse_pages":["A-BROWSE-PAGE"],"topics":["A-TOPIC"],"organisations":[],"parent":["A-BROWSE-PAGE"]}}'
    assert_requested :put, "http://publishing-api.dev.gov.uk/v2/links/B",
      body: '{"links":{"mainstream_browse_pages":["A-BROWSE-PAGE"],"topics":[],"organisations":["AN-ORGANISATION"],"parent":["A-BROWSE-PAGE"]}}'
    assert_requested :put, "http://publishing-api.dev.gov.uk/v2/links/C",
      body: '{"links":{"mainstream_browse_pages":[],"topics":[],"organisations":[]}}'
  end

  test "skips sending the parent tag for travel advice publisher" do
    create(:live_tag, tag_id: "a-browse-page", tag_type: "section", content_id: "A-BROWSE-PAGE")

    create(:artefact,
      content_id: "A",
      slug: "item-a",
      owning_app: "travel-advice-publisher",
      sections: ["a-browse-page"],
    )

    stub_request(:put, %r[#{Plek.find('publishing-api')}/v2/links/*]).
      to_return(body: {}.to_json)

    TaggingMigrator.new("travel-advice-publisher").migrate!

    assert_requested :put, "http://publishing-api.dev.gov.uk/v2/links/A",
      body: '{"links":{"mainstream_browse_pages":["A-BROWSE-PAGE"],"topics":[],"organisations":[]}}'
  end
end
