require File.expand_path('../../panopticon', __FILE__)
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class PanopticonTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_returns_an_http_201_for_success
    params = {:name => 'james', :owning_app => 'guides'}
    post '/slugs', :slug => params
    assert_equal 201, last_response.status
  end
  
  def test_it_returns_an_http_406_for_duplicate_slug
    params = {:name => 'james', :owning_app => 'guides'}
    post '/slugs', :slug => params
    post '/slugs', :slug => params
    assert_equal 406, last_response.status
  end
  
end
