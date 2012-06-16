Given /^I have stubbed search and router$/ do
  stub_search
  stub_router
end

When /^I put a new smart answer's details into panopticon$/ do

  stub_search
  stub_router
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
  # We allow one request to search. FakeWeb will decrement
  # the allowed number of requests each time one is made
  assert_equal 1, @fake_search.first.options[:times] - @fake_search.first.times
end

Then /^the router should be notified$/ do
  # We allow one request to the router. FakeWeb will decrement
  # the allowed number of requests each time one is made
  assert_equal 1, @fake_router.first.options[:times] - @fake_router.first.times
end