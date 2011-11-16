Given /^((?:"[^"]*"(?:, | and )?)+) (?:is|are) related to "(.*)"$/ do |artefact_names, name|
  relate_records_to_artefact_called name, :related_artefacts, split_names(artefact_names)
end

Given /^((?:"[^"]*"(?:, | and )?)+) (?:is|are) (?:a )?contacts? for "(.*)"$/ do |contact_names, name|
  relate_records_to_artefact_called name, :contacts, split_names(contact_names)
end

Given /^no notifications have been sent$/ do
  flush_notifications
end

When /^I am editing "(.*)"$/ do |name|
  visit edit_artefact_path(artefact_called(name))
end

When /^I add "(.*)" as a related item$/ do |name|
  select_within 'Related items', name
end

When /^I add "(.*)" as a contact$/ do |name|
  select_within 'Contacts', name
end

When /^I remove "(.*)" as a related item$/ do |name|
  unselect_within 'Related items', name
end

When /^I remove "(.*)" as a contact$/ do |name|
  unselect_within 'Contacts', name
end

When /^I save my changes$/ do
  click_on 'Satisfy my need'
end

Then /^I should be redirected to "(.*)" on (.*)$/ do |name, app|
  assert_match %r{^#{Regexp.escape Plek.current.find(app)}/}, current_url
  assert_equal artefact_called(name).admin_url, current_url
end

Then /^the rest of the system should be notified that "(.*)" has been updated$/ do |name|
  artefact = artefact_called name
  assert_equal '/topic/marples.panopticon.artefacts.updated', latest_notification[:destination]
  assert_equal artefact.slug, latest_notification[:message][:artefact][:slug]
end

Then /^the API should say that ((?:"[^"]*"(?:, | and )?)+) (?:is|are) (not )?related to "(.*)"$/ do |artefact_names, not_related, name|
  assert_api_relates_records_to_artefact_called(name, Artefact, split_names(artefact_names), not_related) \
    { |data| data[:related_items].map { |related_item| related_item[:artefact][:id] } }
end

Then /^the API should say that ((?:"[^"]*"(?:, | and )?)+) (?:is|are) (not )?(?:a )?contacts? for "(.*)"$/ do |contact_names, not_related, name|
  assert_api_relates_records_to_artefact_called(name, Contact, split_names(contact_names), not_related) \
    { |data| data[:contacts].map { |contact| contact[:id] } }
end
