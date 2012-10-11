Given /^a category tag called "(.*?)" exists$/ do |tag_name|
  @tag = Tag.create!(tag_type: 'section', title: tag_name,
    tag_id: tag_name.parameterize)
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
