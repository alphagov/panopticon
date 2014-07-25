Given /^a tag exists$/ do
  @tag = create(:tag)
end

Given /^a draft tag exists$/ do
  @tag = create(:draft_tag)
end

When /^I create a new tag$/ do
  visit new_tag_path
  fill_in_tag_attributes_in_form
  click_on "Create tag"
end

When /^I edit the tag$/ do
  visit edit_tag_path(@tag)
  fill_in_updated_tag_attributes_in_form
  click_on "Save"
end

When /^I publish the tag$/ do
  visit edit_tag_path(@tag)
  click_on "Publish"
end

Then /^the tag should appear in the list$/ do
  visit tags_path
  assert_tag_present_in_list
end

Then /^the updated tag should appear in the list$/ do
  visit tags_path
  assert_updated_tag_present_in_list
end

Then /^the tag should be marked as draft in the list$/ do
  visit tags_path
  assert_draft_tag_in_list
end

Then /^the tag should appear as live$/ do
  visit edit_tag_path(@tag)
  assert_state_on_edit_form 'live'
end
