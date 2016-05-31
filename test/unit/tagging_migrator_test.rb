require_relative "../test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class TaggingMigratorTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

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

    stub_any_publishing_api_patch_links

    TaggingMigrator.new("smartanswers").migrate!

    assert_publishing_api_patch_links('A', links: { mainstream_browse_pages: ['A-BROWSE-PAGE'], topics: ['A-TOPIC'], organisations: [], parent: ['A-BROWSE-PAGE']}, bulk_publishing: true)
    assert_publishing_api_patch_links('B', links: { mainstream_browse_pages: ['A-BROWSE-PAGE'], topics: [], organisations: ['AN-ORGANISATION'], parent: ['A-BROWSE-PAGE']}, bulk_publishing: true)
    assert_publishing_api_patch_links('C', links: { mainstream_browse_pages: [], topics: [], organisations: []}, bulk_publishing: true)
  end

  test "only sends requested link types to the publishing-api if specified" do
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

    stub_any_publishing_api_patch_links

    TaggingMigrator.new("smartanswers", link_types: [:topics, :organisations]).migrate!

    assert_publishing_api_patch_links('A', links: { topics: ['A-TOPIC'], organisations: []}, bulk_publishing: true)
    assert_publishing_api_patch_links('B', links: { topics: [], organisations: ['AN-ORGANISATION']}, bulk_publishing: true)
    assert_publishing_api_patch_links('C', links: { topics: [], organisations: []}, bulk_publishing: true)
  end

  test "skips sending the parent tag for travel advice publisher" do
    create(:live_tag, tag_id: "a-browse-page", tag_type: "section", content_id: "A-BROWSE-PAGE")

    create(:artefact,
      content_id: "A",
      slug: "item-a",
      owning_app: "travel-advice-publisher",
      sections: ["a-browse-page"],
    )

    stub_any_publishing_api_patch_links

    TaggingMigrator.new("travel-advice-publisher").migrate!

    assert_publishing_api_patch_links('A', links: { mainstream_browse_pages: ['A-BROWSE-PAGE'], topics: [], organisations: []}, bulk_publishing: true)
  end
end
