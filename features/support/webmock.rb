require 'webmock'
require 'webmock/cucumber'

include WebMock::API

Before do
  WebMock.disable_net_connect!(:allow_localhost => true)

  # Mock out all publisher URLs
  stub_request(:get, %r{^#{Regexp.escape Plek.current.find('publisher')}/}).to_return(status: 200)
end
