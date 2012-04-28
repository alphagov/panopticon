When /^I post a smart answer's details into panopticon$/ do

  stub_search

  # TODO: Make this work via API Adapters
  # interface = GdsApi::CoreApi.new('test', "http://example.com")
  # interface.register(resource_details)

  post "/registrations.json", resource: example_smart_answer_json
end

Then /^I should have an artefact created$/ do
  assert Artefact.find_by_slug("calculate-married-couples-allowance")
end

Then /^rummager should be notified$/ do
  # assert FakeWeb.last_request.
  assert FakeWeb.last_request.path == "/documents"
  # TODO: Check this more carefully
end
