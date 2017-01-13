Given /^an artefact created by Publisher exists$/ do
  @artefact = create_artefact('publisher')
end

Given /^an artefact exists$/ do
  @artefact = create_artefact
end

Given /^two artefacts exist$/ do
  @artefact, @related_artefact = create_two_artefacts
end

Given /^the first artefact is in draft$/ do
  Artefact.first.update_attributes!('state' => 'draft')
end

When /^I change the need ID of the first artefact$/ do
  visit edit_artefact_path(@artefact)
  @new_need_id = "100001"
  add_need_id @new_need_id
end

When /^I change the slug of the first artefact to "([^"]*)"$/ do |slug|
  visit edit_artefact_path(@artefact)
  fill_in "Slug", :with => slug
end

When /^I save$/ do
  click_button 'Save and continue editing'
end

Then /^I should be redirected back to the edit page$/ do
  assert_includes page.current_url, edit_artefact_path(@artefact)
end

When /^I save, indicating that I want to continue editing afterwards$/ do
  click_button 'Save and continue editing'
end

When /^I save, indicating that I want to go to the item$/ do
  click_button 'Save and go to item'
end

Then /^I should see the edit form again$/ do
  assert page.has_css?('form.artefact')
end

Then /^I should see an indication that the save worked$/ do
  assert_match /Panopticon item updated/, page.body
end

Then /^I should be redirected to (.*)$/ do |app|
  check_redirect app, (@artefact || Artefact.last)
end

Then /^an artefact should have be created with content_id$/ do
  assert Artefact.last.content_id
end

When /^I visit the homepage$/ do
  visit root_path
end

Then /^I should see a link to create an item$/ do
  xpath = "//a[@href='#{new_artefact_path}']"
  assert page.has_xpath?(xpath)
end

When /^I visit the edit page$/ do
  visit edit_artefact_path(@artefact)
end

Then /^I should see a callout$/ do
  callout = "Tagging and related links for this item has moved"
  assert page.has_content?(callout)
end

Then /^I should see a link for tagging the item on content-tagger$/ do
  link = Plek.find('content-tagger') + "/content/#{@artefact.content_id}"
  xpath = "//a[@href='#{link}']"
  assert page.has_xpath?(xpath)
end

When /^I follow the link link to create an item$/ do
  visit new_artefact_path
end

Then /^I should see the artefact form$/ do
  assert page.has_css?('form.artefact')
end

When /^I fill in the form without a need$/ do
  fill_in "Name", with: "A key business need"
  fill_in "Slug", with: "key-business-need"
  select "Answer", from: "Kind"
end

When /^I try to create a new artefact with the same need$/ do
  visit new_artefact_path(:artefact => {:need_id => @artefact.need_ids.first})
end
