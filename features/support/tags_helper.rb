module TagsHelper
  def fill_in_tag_attributes_in_form
    fill_in "Title", with: "Citizenship"
    fill_in "Slug", with: "citizenship"
    select "Section", from: "Type"
  end

  def fill_in_updated_tag_attributes_in_form
    fill_in "Title", with: "Driving"
    fill_in "Description", with: "Here in my car"
  end

  def assert_tag_present_in_list
    within ".tags-list li:first" do
      assert page.has_content?("Section: Citizenship")
    end
  end

  def assert_updated_tag_present_in_list
    within ".tags-list li:first" do
      assert page.has_content? "Section: Driving"
    end
  end

  def assert_draft_tag_in_list
    within ".tags-list li:first" do
      assert page.has_selector?(".draft", text: "draft")
    end
  end

  def assert_state_on_edit_form(state)
    assert page.has_selector?(".state-#{state}", text: state)
  end
end

World(TagsHelper)
