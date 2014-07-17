require_relative '../integration_test_helper'

class ListingTagsTest < ActionDispatch::IntegrationTest

  setup do
    login_as_user_with_permission('manage_tags')
  end

  should "display tags in alphabetical order grouped by their parent" do
    business = create(:live_tag, tag_id: "business", title: "Business", tag_type: "section")
    children = [
      create(:live_tag, tag_id: "business/setting-up", title: "Setting up", tag_type: "section", parent_id: business.tag_id),
      create(:live_tag, tag_id: "business/manufacturing", title: "Manufacturing", tag_type: "section", parent_id: business.tag_id)
    ]
    driving = create(:live_tag, tag_id: "driving", title: "Driving", tag_type: "section")

    visit tags_path

    within "ul.tags-list" do
      within "li.parent-tag:nth-of-type(1)" do
        assert page.has_content?('Section: Business')

        assert page.has_link?('Edit tag', href: edit_tag_path(business))
        assert page.has_link?('Add child tag', href: new_tag_path(type: 'section', parent_id: 'business'))

        within ".children li:nth-of-type(1)" do
          assert page.has_content?('Manufacturing')
          assert page.has_link?('business/manufacturing', href: "http://www.dev.gov.uk/browse/business/manufacturing")

          assert page.has_link?('Edit tag', href: edit_tag_path(children[1]))
        end

        within ".children li:nth-of-type(2)" do
          assert page.has_content?('Setting up')
          assert page.has_link?('business/setting-up', href: "http://www.dev.gov.uk/browse/business/setting-up")

          assert page.has_link?('Edit tag', href: edit_tag_path(children[0]))
        end
      end

      within "li.parent-tag:nth-of-type(2)" do
        assert page.has_content?('Section: Driving')

        assert page.has_link?('Edit tag', href: edit_tag_path(driving))
        assert page.has_link?('Add child tag', href: new_tag_path(type: 'section', parent_id: 'driving'))
      end
    end
  end

  should 'display a draft label on draft tags' do
    draft_tag = create(:draft_tag, tag_id: 'business', title: 'Business', tag_type: 'section')
    child_draft_tag = create(:draft_tag, tag_id: "business/setting-up", title: "Setting up", tag_type: "section", parent_id: draft_tag.tag_id)

    visit tags_path

    within 'ul.tags-list li.parent-tag' do
      assert page.has_content?('Section: Business')
      assert page.has_selector?('.draft', text: 'draft')

      within '.children li' do
        assert page.has_content?('Setting up')
        assert page.has_selector?('.draft', text: 'draft')
      end
    end
  end

  should 'not display a draft label on live tags' do
    live_tag = create(:live_tag, tag_id: 'business', title: 'Business', tag_type: 'section')
    child_live_tag = create(:live_tag, tag_id: "business/setting-up", title: "Setting up", tag_type: "section", parent_id: live_tag.tag_id)

    visit tags_path

    within 'ul.tags-list li.parent-tag' do
      assert page.has_content?('Section: Business')
      assert page.has_no_selector?('.draft')

      within '.children li' do
        assert page.has_content?('Setting up')
        assert page.has_no_selector?('.draft')
      end
    end
  end

end
