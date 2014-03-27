require_relative '../integration_test_helper'

class ListingTagsTest < ActionDispatch::IntegrationTest

  setup do
    create_test_user
  end

  should "display tags in alphabetical order grouped by their parent" do
    business = create(:tag, tag_id: "business", title: "Business", tag_type: "section")
    children = [
      create(:tag, tag_id: "business/setting-up", title: "Setting up", tag_type: "section", parent_id: business.tag_id),
      create(:tag, tag_id: "business/manufacturing", title: "Manufacturing", tag_type: "section", parent_id: business.tag_id)
    ]
    driving = create(:tag, tag_id: "driving", title: "Driving", tag_type: "section")

    visit tags_path

    within "table#tags-list tbody" do
      within "tr.parent:nth-of-type(1)" do
        assert page.has_content?('Business')
        assert page.has_link?('business', href: "http://www.dev.gov.uk/browse/business")
        assert page.has_content?('section')

        assert page.has_link?('edit', href: edit_tag_path(business))
      end

      within "tr:nth-of-type(2)" do
        assert page.has_content?('Manufacturing')
        assert page.has_link?('business/manufacturing', href: "http://www.dev.gov.uk/browse/business/manufacturing")
        assert page.has_content?('section')

        assert page.has_link?('edit', href: edit_tag_path(children[1]))
      end

      within "tr:nth-of-type(3)" do
        assert page.has_content?('Setting up')
        assert page.has_link?('business/setting-up', href: "http://www.dev.gov.uk/browse/business/setting-up")
        assert page.has_content?('section')

        assert page.has_link?('edit', href: edit_tag_path(children[0]))
      end

      within "tr.parent:nth-of-type(4)" do
        assert page.has_content?('Driving')
        assert page.has_link?('driving', href: "http://www.dev.gov.uk/browse/driving")
        assert page.has_content?('section')

        assert page.has_link?('edit', href: edit_tag_path(driving))
      end
    end
  end

end
