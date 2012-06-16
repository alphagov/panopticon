When /^I put a new smart answer's details into panopticon$/ do

  stub_search
  setup_user

  # TODO: Make this work via API Adapters
  # interface = GdsApi::CoreApi.new('test', "http://example.com")
  # interface.register(resource_details)

  put "/artefacts/#{example_smart_answer['slug']}.json", artefact: example_smart_answer
end

Then /^a new artefact should be created$/ do
  assert_equal 201, last_response.status, last_response.inspect
end

Then /^rummager should be notified$/ do
  # assert FakeWeb.last_request.
  assert FakeWeb.last_request.path == "/documents"
  # TODO: Check this more carefully
end
