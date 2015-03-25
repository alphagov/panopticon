require_relative "../integration_test_helper"

class ShowingTagsTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_with_permission("manage_tags")

    # stub the router + rummager requests so that artefact creation doesn't
    # fire off a bunch of web requests
    stub_all_router_api_requests
    stub_all_rummager_requests
  end

  should "display the tag details" do
    @tag = create(:live_tag, tag_type: "section",
                  tag_id: "driving",
                  title: "Driving",
                  description: "Car tax, MOTs and driving licences")

    visit tag_path(@tag)

    within "header.artefact-header" do
      assert page.has_content?("Section: Driving")
      assert page.has_link?("/browse/driving", href: "http://www.dev.gov.uk/browse/driving")
      assert page.has_selector?(".state-live", text: "live")
    end

    within ".well" do
      assert page.has_text?(@tag.description)
    end
  end

  should "state the tag is in draft when displaying the tag details" do
    @tag = create(:draft_tag, tag_type: "section",
                  tag_id: "driving",
                  title: "Driving",
                  description: "Car tax, MOTs and driving licences")

    visit tag_path(@tag)

    within "header.artefact-header" do
      assert page.has_content?("Section: Driving")
      refute page.has_link?("/browse/driving", href: "http://www.dev.gov.uk/browse/driving")
      assert page.has_selector?(".state-draft", text: "draft")
    end
  end
end
