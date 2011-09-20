require 'test_helper'

class ArtefactsControllerTest < ActiveSupport::TestCase
  def test_it_redirects_to_the_publisher
    params = {
      :need_id => 12345,
      :kind => "guide",
      :name => "Name Of Guide",
      :tags => "test, foo, bar"
    }

    post '/artefacts', :artefact => params

    assert_equal 303, last_response.status
    assert_equal Plek.current.publisher + '/admin/guides/new?guide[name]=Name+Of+Guide&guide[slug]=name-of-guide&guide[tags]=test%2C+foo%2C+bar', last_response.header['Location']
  end
end
