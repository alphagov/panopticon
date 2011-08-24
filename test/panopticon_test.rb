ENV['RACK_ENV'] = 'test'
require File.expand_path('../../panopticon', __FILE__)
require 'test/unit'
require 'rack/test'

class PanopticonTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_returns_an_http_201_for_success
    params = {:name => 'james', :owning_app => 'guides', :kind => 'guide'}
    post '/slugs', :slug => params
    assert_equal 201, last_response.status
  end
  
  def test_it_returns_an_http_406_for_duplicate_slug
    params = {:name => 'james', :owning_app => 'guides', :kind => 'blah'}
    post '/slugs', :slug => params
    post '/slugs', :slug => params
    assert_equal 406, last_response.status
  end

  def test_get_returns_details_as_json
    params = {:name => 'another-james', :owning_app => 'guides', :kind => 'blah'}
    post '/slugs', :slug => params
    get '/slugs/another-james'
    assert_equal 200, last_response.status
    assert_equal 'blah', JSON.parse(last_response.body)['kind']
  end
    
  def test_get_returns_an_http_404_for_unknown_slug
    get '/slugs/something-new'
    assert_equal 404, last_response.status
  end
  
end
