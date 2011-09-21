require 'test_helper'

class ArtefactsControllerTest < ActiveSupport::TestCase
  def test_it_redirects_to_the_publisher
    artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever'
    get '/artefacts/' + artefact.to_param

    assert_equal 302, last_response.status
    assert_equal Plek.current.publisher + "/admin/publications/#{artefact.to_param}", last_response.header['Location']
  end
end
