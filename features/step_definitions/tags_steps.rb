When /^I create a new tag$/ do
  visit new_tag_path
  fill_in_tag_attributes_in_form
  click_on "Create Tag"
end

Then /^the tag should appear in the list$/ do
  visit tags_path
  assert_tag_present_in_list
end
