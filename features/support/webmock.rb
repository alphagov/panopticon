require 'webmock'
require 'webmock/cucumber'

include WebMock::API

WebMock.disable_net_connect!

Before do
  # Mock out all publisher URLs
  stub_request(:get, %r{^#{Regexp.escape Plek.current.find('publisher')}/}).to_return(status: 200)

  stub_request(:get, "#{Plek.current.find('data')}/data_sets/public_bodies.json").to_return(body: [].to_json)
end