Given /^two artefacts exist$/ do
  @artefact, @related_artefact = create_two_artefacts
  flush_notifications
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
