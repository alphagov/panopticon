module TagsHelper
  def fill_in_tag_attributes_in_form
    fill_in "Title", with: "Citizenship"
    fill_in "Slug", with: "citizenship"
    select "section", from: "Type"
  end

  def assert_tag_present_in_list
    within "table tbody tr:first" do
      assert page.has_content?("Citizenship")
      assert page.has_content?("citizenship")
      assert page.has_content?("section")
    end
  end
end

World(TagsHelper)
