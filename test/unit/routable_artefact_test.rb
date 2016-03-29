require 'test_helper'
require 'gds_api/test_helpers/router'

class RoutableArtefactTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Router

  context "submitting a live artefact" do
    context "for a Whitehall artefact" do
      setup do
        stub_artefact_callbacks
        @artefact = FactoryGirl.create(:whitehall_live_artefact,
                                       owning_app: "whitehall",
                                       paths: ["/foo"])
        @routable = RoutableArtefact.new(@artefact)
        @routable.stubs(:ensure_backend_exists).returns true
      end

      should "register the route" do
        @routable.expects(:register)
        @routable.expects(:commit)

        @routable.submit
      end

      should "register the route for an archived detailed guide" do
        @routable.expects(:register)
        @routable.expects(:commit)

        @artefact.kind = "detailed_guide"
        @artefact.state = "archived"

        @routable.submit
      end

      should "not set an archived route as Gone" do
        @routable.expects(:delete).never
        @routable.expects(:commit).never

        @artefact.state = "archived"

        @routable.submit
      end

      should "not add a redirect" do
        @routable.expects(:redirect).never
        @routable.expects(:commit).never

        @artefact.state = "archived"
        @artefact.redirect_url = "/bar"

        @routable.submit
      end
    end

    context "for a non-Whitehall artefact" do
      setup do
        stub_artefact_callbacks
        @artefact = FactoryGirl.create(:live_artefact,
                                       owning_app: "bee",
                                       paths: ["/foo"])
        @routable = RoutableArtefact.new(@artefact)
        @routable.stubs(:ensure_backend_exists).returns true
      end

      should "register the route" do
        @routable.expects(:register)
        @routable.expects(:commit)

        @routable.submit
      end

      should "set an archived route as Gone" do
        @routable.expects(:delete)
        @routable.expects(:commit)

        @artefact.state = "archived"

        @routable.submit
      end

      should "add a redirect if requested" do
        @routable.expects(:redirect).with("/bar")
        @routable.expects(:commit)

        @artefact.state = "archived"
        @artefact.redirect_url = "/bar"

        @routable.submit
      end
    end
  end

  context "registering routes for an artefact" do
    setup do
      stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
      @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
      @routable = RoutableArtefact.new(@artefact)
      stub_all_router_registration
    end

    context "ensuring the backend exists in the router" do
      should "use the rendering_app if set" do
        @artefact.rendering_app = "fooey"
        request = stub_router_backend_registration("fooey", "http://fooey.dev.gov.uk/")
        @routable.register
        assert_requested request
      end

      should "use the owning_app if rendering_app not set" do
        @artefact.rendering_app = nil
        request = stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
        @routable.register
        assert_requested request
      end

      should "use the owning_app if rendering_app is blank" do
        @artefact.rendering_app = ""
        request = stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
        @routable.register
        assert_requested request
      end
    end

    should "add all defined prefix routes" do
      requests = [
        stub_route_registration("/foo", "prefix", "bee"),
        stub_route_registration("/bar", "prefix", "bee"),
        stub_route_registration("/baz", "prefix", "bee")
      ]

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.register

      requests.each do |route_request, _commit_request|
        assert_requested route_request
      end
    end

    should "add all defined exact routes" do
      requests = [
        stub_route_registration("/foo.json", "exact", "bee"),
        stub_route_registration("/bar", "exact", "bee")
      ]

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.register

      requests.each do |route_request, _commit_request|
        assert_requested route_request
      end
    end

    should "not blow up if prefixes or paths is nil" do
      @artefact.prefixes = nil
      @artefact.paths = nil
      assert_nothing_raised do
        @routable.register
      end
    end
  end

  context "deleting routes for an artefact" do
    setup do
      stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
      @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
      @routable = RoutableArtefact.new(@artefact)
    end

    should "delete all defined prefix routes" do
      requests = [
        stub_gone_route_registration("/foo", "prefix"),
        stub_gone_route_registration("/bar", "prefix"),
        stub_gone_route_registration("/baz", "prefix")
      ]

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.delete

      requests.each do |route_request, _commit_request|
        assert_requested route_request
      end
    end

    should "delete all defined exact routes" do
      requests = [
        stub_gone_route_registration("/foo.json", "exact"),
        stub_gone_route_registration("/bar", "exact")
      ]

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.delete

      requests.each do |route_request, _commit_request|
        assert_requested route_request
      end
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
        gone_request, _commit_request = stub_gone_route_registration(
          "/foo", "prefix")

        gone_request.to_return(status: 404)

        @artefact.prefixes = ["/foo"]
        assert_nothing_raised do
          @routable.delete
        end
      end

      should "continue to delete other routes" do
        missing_gone_request, _commit_request = stub_gone_route_registration(
          "/foo", "prefix")
        missing_gone_request.to_return(status: 404)

        gone_request, _commit_request = stub_gone_route_registration(
          "/bar", "prefix")

        @artefact.prefixes = ["/foo", "/bar"]
        @routable.delete

        assert_requested gone_request
      end
    end
  end

  context "redirecting routes for an artefact" do
    setup do
      stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
      @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
      @routable = RoutableArtefact.new(@artefact)
    end

    should "redirect all defined prefix routes" do
      requests = [
        stub_redirect_registration("/foo", "prefix", "/new", "permanent", "ignore"),
        stub_redirect_registration("/bar", "prefix", "/new", "permanent", "ignore"),
        stub_redirect_registration("/baz", "prefix", "/new", "permanent", "ignore")
      ]

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.redirect("/new")

      requests.each do |redirect_request, _commit_request|
        assert_requested redirect_request
      end
    end

    should "redirect all defined exact routes" do
      requests = [
        stub_redirect_registration("/foo.json", "exact", "/new", "permanent"),
        stub_redirect_registration("/bar", "exact", "/new", "permanent")
      ]

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.redirect("/new")

      requests.each do |redirect_request, _commit_request|
        assert_requested redirect_request
      end
    end

    should "not blow up if prefixes or paths is nil" do
      @artefact.prefixes = nil
      @artefact.paths = nil
      assert_nothing_raised do
        @routable.redirect("/new")
      end
    end

    context "when router-api returns 404 for a delete request" do
      should "not blow up" do
        gone_request, _commit_request = stub_redirect_registration(
          "/foo", "prefix", "/new", "permanent", "ignore")

        gone_request.to_return(status: 404)

        @artefact.prefixes = ["/foo"]
        assert_nothing_raised do
          @routable.redirect("/new")
        end
      end

      should "continue to redirect other routes" do
        missing_redirect_request, _commit_request = stub_redirect_registration(
          "/foo", "prefix", "/new", "permanent", "ignore")
        missing_redirect_request.to_return(status: 404)

        redirect_request, _commit_request = stub_redirect_registration(
          "/bar", "prefix", "/new", "permanent", "ignore")

        @artefact.prefixes = ["/foo", "/bar"]
        @routable.redirect("/new")

        assert_requested redirect_request
      end
    end
  end
end
