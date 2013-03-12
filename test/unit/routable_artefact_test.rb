require_relative '../test_helper'

class RoutableArtefactTest < ActiveSupport::TestCase
  setup do
    @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
    @routable = RoutableArtefact.new(@artefact)
  end

  context "registering the application" do
    should "ensure that the application exists in the router" do
      Router.any_instance.expects(:update_application).with("bee", "bee.dev.gov.uk")
      Router.any_instance.stubs(:create_route)
      @routable.submit
    end

    should "strip the scheme from the URL returned by Plek" do
      # Plek returns the external URL's for applications, this is the HTTPS version
      # in preview and production.  If an https URL is passed to the router, it gets confused.
      Plek.any_instance.stubs(:find).with('bee').returns("https://bee.dev.gov.uk")

      Router.any_instance.expects(:update_application).with("bee", "bee.dev.gov.uk")
      Router.any_instance.stubs(:create_route)
      @routable.submit
    end
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

  context "the slug is also a prefix" do
    setup do
      @artefact.prefixes = [@artefact.slug]
    end

    should "send it as a prefix, and not send a full route" do
      Router.any_instance.stubs(:update_application)
      Router.any_instance.expects(:create_route).with(@artefact.slug, "prefix", "bee")
      @routable.submit
    end
  end

  should "use the internal hostname for frontend" do
    # Was previously using the publically visible hostname (www...) which was breaking things.
    Plek.any_instance.stubs('find').with('frontend').returns("https://frontend.production.alphagov.co.uk")
    @artefact.update_attributes!(:owning_app => 'frontend')
    Router.any_instance.expects(:update_application).with("frontend", "frontend.production.alphagov.co.uk")
    Router.any_instance.stubs(:create_route)
    @routable.submit
  end

  context "deleting routes for an artefact" do

    should "delete the artefact slug from the router" do
      Router.any_instance.expects(:delete_route).with(@artefact.slug)
      @routable.delete
    end

    should "delete all paths and prefixes as well as the slug" do
      @artefact.paths = ["foo", "bar"]
      @artefact.prefixes = ["baz"]
      Router.any_instance.expects(:delete_route).with(@artefact.slug)
      Router.any_instance.expects(:delete_route).with("foo")
      Router.any_instance.expects(:delete_route).with("bar")
      Router.any_instance.expects(:delete_route).with("baz")
      @routable.delete
    end

    should "cope with paths or prefixes being set to nil" do
      @artefact.paths = nil
      @artefact.prefixes = nil
      Router.any_instance.expects(:delete_route).with(@artefact.slug)
      assert_nothing_raised do
        @routable.delete
      end
    end
  end
end
