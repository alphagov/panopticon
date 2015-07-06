require_relative '../test_helper'

class RoutableArtefactTest < ActiveSupport::TestCase
  setup do
    @old_app_domain, ENV['GOVUK_APP_DOMAIN'] = ENV['GOVUK_APP_DOMAIN'], 'test.gov.uk'
    @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
    @routable = RoutableArtefact.new(@artefact)
  end

  teardown do
    ENV['GOVUK_APP_DOMAIN'] = @old_app_domain
  end

  context "registering routes for an artefact" do
    setup do
      GdsApi::Router.any_instance.stubs(:add_backend)
      GdsApi::Router.any_instance.stubs(:add_route)
      GdsApi::Router.any_instance.stubs(:commit_routes)
    end

    context "ensuring the backend exists in the router" do
      should "use the rendering_app if set" do
        @artefact.rendering_app = "fooey"
        GdsApi::Router.any_instance.expects(:add_backend).with("fooey", "http://fooey.test.gov.uk/")
        @routable.submit
      end

      should "use the owning_app if rendering_app not set" do
        @artefact.rendering_app = nil
        GdsApi::Router.any_instance.expects(:add_backend).with("bee", "http://bee.test.gov.uk/")
        @routable.submit

        @artefact.rendering_app = ""
        GdsApi::Router.any_instance.expects(:add_backend).with("bee", "http://bee.test.gov.uk/")
        @routable.submit
      end
    end

    should "add all defined prefix routes" do
      GdsApi::Router.any_instance.expects(:add_route).with("/foo", "prefix", "bee")
      GdsApi::Router.any_instance.expects(:add_route).with("/bar", "prefix", "bee")
      GdsApi::Router.any_instance.expects(:add_route).with("/baz", "prefix", "bee")

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.submit
    end

    should "add all defined exact routes" do
      GdsApi::Router.any_instance.expects(:add_route).with("/foo.json", "exact", "bee")
      GdsApi::Router.any_instance.expects(:add_route).with("/bar", "exact", "bee")

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.submit
    end

    should "commit the route changes" do
      GdsApi::Router.any_instance.expects(:commit_routes)

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @artefact.paths = ["/foo.json"]
      @routable.submit
    end

    should "not commit when asked not to" do
      @routable.router_api.expects(:commit_routes).never

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @artefact.paths = ["/foo.json"]
      @routable.submit(:skip_commit => true)
    end

    should "not blow up if prefixes or paths is nil" do
      @artefact.prefixes = nil
      @artefact.paths = nil
      assert_nothing_raised do
        @routable.submit
      end
    end
  end

  context "deleting routes for an artefact" do
    setup do
      GdsApi::Router.any_instance.stubs(:delete_route)
      GdsApi::Router.any_instance.stubs(:commit_routes)
    end

    should "delete all defined prefix routes" do
      GdsApi::Router.any_instance.expects(:delete_route).with("/foo")
      GdsApi::Router.any_instance.expects(:delete_route).with("/bar")
      GdsApi::Router.any_instance.expects(:delete_route).with("/baz")

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.delete
    end

    should "delete all defined exact routes" do
      GdsApi::Router.any_instance.expects(:delete_route).with("/foo.json")
      GdsApi::Router.any_instance.expects(:delete_route).with("/bar")

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.delete
    end

    should "commit the routes" do
      GdsApi::Router.any_instance.expects(:commit_routes)

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @artefact.paths = ["/foo.json"]
      @routable.delete
    end

    should "not commit when asked not to" do
      @routable.router_api.expects(:commit_routes).never

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @artefact.paths = ["/foo.json"]
      @routable.delete(:skip_commit => true)
    end


    should "not blow up if prefixes or paths is nil" do
      @artefact.prefixes = nil
      @artefact.paths = nil
      assert_nothing_raised do
        @routable.delete
      end
    end

    context "when router-api returns 404 for a delete request" do
      should "not blow up" do
        GdsApi::Router.any_instance.stubs(:delete_route).raises(GdsApi::HTTPNotFound.new(404))

        @artefact.prefixes = ["/foo"]
        assert_nothing_raised do
          @routable.delete
        end
      end

      should "continue to delete other routes" do
        GdsApi::Router.any_instance.stubs(:delete_route).with("/foo").raises(GdsApi::HTTPNotFound.new(404))
        GdsApi::Router.any_instance.expects(:delete_route).with("/bar")

        @artefact.prefixes = ["/foo", "/bar"]
        @routable.delete
      end
    end
  end
end
