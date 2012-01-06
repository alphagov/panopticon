Given /^two artefacts exist$/ do
  @artefact, @related_artefact = create_two_artefacts
  flush_notifications
end

When /^I mark relatedness as done$/ do
  check :relatedness_done
end

When /^I change the title of the first artefact$/ do
  visit edit_artefact_path(@artefact)
  fill_in "Name", :with => 'Some other new name'
end

When /^I change the slug of the first artefact to "([^"]*)"$/ do |slug|
  visit edit_artefact_path(@artefact)
  fill_in "Slug", :with => slug
end

When /^I save$/ do
  click_button 'Save and continue editing'
end

Then /^I should be redirected back to the edit page$/ do
  assert_equal edit_artefact_url(@artefact), page.current_url
end

Then /^I should see an indication that the save failed$/ do
  assert page.has_content?('Failed to save item')
  assert page.has_content?('must be usable in a URL')
end

When /^I save, indicating that I want to continue editing afterwards$/ do
  click_button 'Save and continue editing'
end

Then /^I should see the edit form again$/ do
  assert page.has_css?('form.artefact')
end

Then /^I should see an indication that the save worked$/ do
  assert_match /Panopticon item updated/, page.body
end

When /^I create a relationship between them$/ do
  visit edit_artefact_path(@artefact)
  select_related_artefact @related_artefact
  submit_artefact_form
end

Then /^I should be redirected to (.*)$/ do |app|
  check_redirect app, @artefact
end

Given /^the artefacts are related$/ do
  add_related_artefact @artefact, @related_artefact
  flush_notifications
end

When /^I destroy their relationship$/ do
  visit edit_artefact_path(@artefact)
  unselect_related_artefact @related_artefact
  submit_artefact_form
end

Given /^several artefacts exist$/ do
  @artefact, *@related_artefacts, @unrelated_artefact = create_six_artefacts
  flush_notifications
end

Given /^some of the artefacts are related$/ do
  add_related_artefacts @artefact, @related_artefacts[0...(@related_artefacts.length / 2)]
  flush_notifications
end

When /^I create more relationships between them$/ do
  visit edit_artefact_path(@artefact)
  select_related_artefacts @related_artefacts[(@related_artefacts.length / 2)..-1]
  submit_artefact_form
end

Given /^an artefact exists$/ do
  @artefact = create_artefact
  flush_notifications
end

When /^I add the contact to the artefact$/ do
  visit edit_artefact_path(@artefact)
  select_contact @contact
  submit_artefact_form
end

Given /^the artefact has the contact$/ do
  add_contact @artefact, @contact
  flush_notifications
end

When /^I remove the contact from the artefact$/ do
  visit edit_artefact_path(@artefact)
  unselect_contact @contact
  submit_artefact_form
end
