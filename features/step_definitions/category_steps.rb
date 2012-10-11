Given /^a category tag called "(.*?)" exists$/ do |tag_name|
  @tag = Tag.create!(tag_type: 'section', title: tag_name,
    tag_id: tag_name.parameterize)
end

Given /^my basic set of tags exist$/ do
  Tag.create!(tag_id: 'employing-people/pensions', title: 'Pensions',
    tag_type: 'section')
  Tag.create!(tag_id: 'business/selling-closing', title: 'Selling and closing',
    tag_type: 'section')
end

When /^I visit the curated list admin page$/ do
  visit curated_list_path
end

When /^I upload my CSV file$/ do
  attach_file "CSV of curated lists", csv_path_for_data("curated_list_dummy")
  click_button "Upload CSV"
end

When /^I visit the categories page$/ do
  visit categories_path
end

When /^I follow the link to edit the category$/ do
  click_link @tag.tag_id
end

When /^I change the category title to "(.*?)"$/ do |new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

Then /^I should be on the categories page$/ do
  assert_equal categories_path, page.current_url
end

Then /^I should see "(.*?)"$/ do |content|
  assert_match /#{content}/, page.body
end

Then /^the curated lists should exist$/ do
  Tag.where(tag_type: 'section').each do |t|
    assert CuratedList.any_in(tag_ids: [t.tag_id]).first, "List for #{t.tag_id} missing"
  end
end