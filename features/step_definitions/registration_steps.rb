Given /^I have stubbed search$/ do
  stub_search
end

When /^I put a new news item's details into panopticon$/ do
  prepare_registration_environment

  put "/artefacts/#{example_news_item['slug']}.json", artefact: example_news_item
end

When /^I put an updated person's details into panopticon$/ do
  prepare_registration_environment
  setup_existing_artefact

  artefact_basics = example_person
  artefact_basics['name'] = 'Something simpler'
  put "/artefacts/#{artefact_basics['slug']}.json",
    artefact: artefact_basics
end

When /^I put a draft news item's details into panopticon$/ do
  prepare_registration_environment

  details = example_news_item
  details['state'] = 'draft'

  put "/artefacts/#{example_news_item['slug']}.json", artefact: details
end

When /^I put a new person's details into panopticon$/ do
  prepare_registration_environment(example_person)

  put "/artefacts/#{example_person['slug']}.json", artefact: example_person
end

When /^I put a new item into panopticon whose slug is already taken$/ do
  prepare_registration_environment
  setup_existing_artefact
  artefact_basics = example_person
  artefact_basics['name'] = 'Something simpler'
  artefact_basics['owning_app'] = 'planner'
  put "/artefacts/#{artefact_basics['slug']}.json",
    artefact: artefact_basics
end

When /^I delete an artefact$/ do
  prepare_registration_environment
  setup_existing_artefact
  stub_search_delete

  delete "/artefacts/#{@artefact.slug}.json"
end

Then /^a new artefact should be created$/ do
  assert_equal 201, last_response.status, "Expected 201, got #{last_response.status}"
end

Then /^the relevant artefact should be updated$/ do
  # Check status code of response
  assert_equal 200, last_response.status, "Expected 200, got #{last_response.status}"
end

Then /^I should receive an HTTP (\d+) response$/ do |code|
  assert_equal code.to_i, last_response.status, "Expected #{code}, got #{last_response.status}"
end

Then /^the API should reflect the change$/ do
  check_artefact_has_name_in_api @artefact, 'Something simpler'
end

Then /^the relevant artefact should not be updated$/ do
  assert 'Something simpler' != artefact_data_from_api(@artefact)[:name]
end

Then /^rummager should be notified$/ do
  assert_requested @fake_search, times: 1  # The default, but let's be explicit
end

Then /^rummager should be told to do a partial update$/ do
  amendments = {
    title: "Child Benefit rates",
    format: "course",
    section: @section.tag_id,
    subsection: ""
  }
  assert_requested :post, artefact_search_url(@artefact), body: amendments
end

Then /^rummager should not be notified$/ do
  assert_not_requested @fake_search
end

Then /^the artefact state should be archived$/ do
  assert_equal 'archived', Artefact.last.state
end

Then /^rummager should be notified of the delete$/ do
  assert_requested @fake_search_delete, times: 1  # The default, but let's be explicit
end
