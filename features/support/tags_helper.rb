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
    within "table tbody tr:first" do
      assert page.has_content?("Citizenship")
      assert page.has_content?("citizenship")
      assert page.has_content?("section")
    end
  end

  def assert_updated_tag_present_in_list
    within "table tbody tr:first" do
      assert page.has_content? "Driving"
      assert page.has_content? @tag.tag_id
      assert page.has_content? @tag.tag_type
    end
  end
end

World(TagsHelper)
