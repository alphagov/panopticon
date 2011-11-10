FakeWeb.allow_net_connect = false
FakeWeb.register_uri :get, %r{^#{Regexp.escape Plek.current.find('publisher')}/}, :status => [200, 'OK']
