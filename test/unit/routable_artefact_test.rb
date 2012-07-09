require 'test_helper'

class RouteableArtefactTest < ActiveSupport::TestCase
  setup do
    @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
    @routable = RoutableArtefact.new(@artefact)
  end

  should "ensure that the application exists in the router" do
    Router.any_instance.expects(:update_application).with("bee", "http://bee.test.gov.uk")
    Router.any_instance.stubs(:create_route)
    @routable.submit
  end

  should "create a full route for the slug" do
    Router.any_instance.stubs(:update_application)
    Router.any_instance.expects(:create_route).with(@artefact.slug, "full", "bee")
    @routable.submit
  end
end
