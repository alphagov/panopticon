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

  should "create full routes for paths" do
    @artefact.paths = ["#{@artefact.slug}.json", "#{@artefact.slug}.ics"]
    Router.any_instance.stubs(:update_application)
    Router.any_instance.stubs(:create_route).with(@artefact.slug, "full", "bee")
    Router.any_instance.expects(:create_route).with("#{@artefact.slug}.json", "full", "bee")
    Router.any_instance.expects(:create_route).with("#{@artefact.slug}.ics", "full", "bee")
    @routable.submit
  end

  context "the slug is repeated in one of the paths" do
    setup do
      @artefact.paths = [@artefact.slug]
    end

    should "not (attempt to) register duplicate full routes" do
      Router.any_instance.stubs(:update_application)
      Router.any_instance.expects(:create_route).with(@artefact.slug, "full", "bee")
      @routable.submit
    end
  end

  should "create prefix routes for prefixes" do
    @artefact.prefixes = ["un", "re"]
    Router.any_instance.stubs(:update_application)
    Router.any_instance.stubs(:create_route).with(@artefact.slug, "full", "bee")
    Router.any_instance.expects(:create_route).with("un", "prefix", "bee")
    Router.any_instance.expects(:create_route).with("re", "prefix", "bee")
    @routable.submit
  end
end
