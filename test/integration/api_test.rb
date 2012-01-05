# encoding: UTF-8
require_relative 'integration_test_helper'
require 'gds_api/panopticon'

class ApiAcceptanceTest < ActionDispatch::IntegrationTest
  def server
    @server ||= startup_server
  end
  
  def startup_server
    server = Capybara::Server.new(Capybara.app)
    server.boot
    server
  end

  def create_test_user
    User.create!(name: "Test", email: "test@example.com", uid: 123)
  end
  
  test "Can create an artefact via the api" do
    create_test_user
    api_client = GdsApi::Panopticon.new(nil, endpoint_url: server.url(""), timeout: 5)
    artefact_fixture = {slug: "foo", name: "Foo", owning_app: "Test", kind: "custom-application"}
    
    created = nil
    assert_difference "Artefact.count" do
      created = api_client.create_artefact(artefact_fixture)
    end
    
    assert ! created['id'].nil?
    found_artefact = Artefact.find(created['id'])
    assert artefact_fixture[:slug], found_artefact.slug
    assert artefact_fixture[:name], found_artefact.name
    assert artefact_fixture[:owning_app], found_artefact.owning_app
    assert artefact_fixture[:kind], found_artefact.kind
  end
end
