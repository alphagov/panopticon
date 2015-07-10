require 'test_helper'
require 'gds_api/test_helpers/router'

class RoutableArtefactTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Router

  setup do
    stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
    @artefact = FactoryGirl.create(:artefact, owning_app: "bee")
    @routable = RoutableArtefact.new(@artefact)
  end

  context "registering routes for an artefact" do
    setup do
      stub_all_router_registration
    end

    context "ensuring the backend exists in the router" do
      should "use the rendering_app if set" do
        @artefact.rendering_app = "fooey"
        request = stub_router_backend_registration("fooey", "http://fooey.dev.gov.uk/")
        @routable.submit
        assert_requested request
      end

      should "use the owning_app if rendering_app not set" do
        @artefact.rendering_app = nil
        request = stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
        @routable.submit
        assert_requested request
      end

      should "use the owning_app if rendering_app is blank" do
        @artefact.rendering_app = ""
        request = stub_router_backend_registration("bee", "http://bee.dev.gov.uk/")
        @routable.submit
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
      @routable.submit

      requests.each do |route_request, commit_request|
        assert_requested route_request
        assert_requested commit_request
      end
    end

    should "add all defined exact routes" do
      requests = [
        stub_route_registration("/foo.json", "exact", "bee"),
        stub_route_registration("/bar", "exact", "bee")
      ]

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.submit

      requests.each do |route_request, commit_request|
        assert_requested route_request
        assert_requested commit_request
      end
    end

    should "not commit when asked not to" do
      prefix_route_request, prefix_commit_request = stub_route_registration(
        "/foo", "prefix", "bee")
      exact_route_request, exact_commit_request = stub_route_registration(
        "/bar", "exact", "bee")

      @artefact.prefixes = ["/foo"]
      @artefact.paths = ["/bar"]
      @routable.submit(:skip_commit => true)

      assert_requested prefix_route_request
      assert_requested exact_route_request
      assert_not_requested prefix_commit_request
      assert_not_requested exact_commit_request
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
    should "delete all defined prefix routes" do
      requests = [
        stub_gone_route_registration("/foo", "prefix"),
        stub_gone_route_registration("/bar", "prefix"),
        stub_gone_route_registration("/baz", "prefix")
      ]

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.delete

      requests.each do |route_request, commit_request|
        assert_requested route_request
        assert_requested commit_request
      end
    end

    should "delete all defined exact routes" do
      requests = [
        stub_gone_route_registration("/foo.json", "exact"),
        stub_gone_route_registration("/bar", "exact")
      ]

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.delete

      requests.each do |route_request, commit_request|
        assert_requested route_request
        assert_requested commit_request
      end
    end

    should "not commit when asked not to" do
      prefix_route_request, prefix_commit_request = stub_gone_route_registration(
        "/foo", "prefix")
      exact_route_request, exact_commit_request = stub_gone_route_registration(
        "/bar", "exact")

      @artefact.prefixes = ["/foo"]
      @artefact.paths = ["/bar"]
      @routable.delete(skip_commit: true)

      assert_requested prefix_route_request
      assert_requested exact_route_request
      assert_not_requested prefix_commit_request
      assert_not_requested exact_commit_request
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
        gone_request, commit_request = stub_gone_route_registration(
          "/foo", "prefix")

        gone_request.to_return(status: 404)

        @artefact.prefixes = ["/foo"]
        assert_nothing_raised do
          @routable.delete
        end
      end

      should "continue to delete other routes" do
        missing_gone_request, _ = stub_gone_route_registration(
          "/foo", "prefix")
        missing_gone_request.to_return(status: 404)

        gone_request, commit_request = stub_gone_route_registration(
          "/bar", "prefix")

        @artefact.prefixes = ["/foo", "/bar"]
        @routable.delete

        assert_requested gone_request
        assert_requested commit_request
      end
    end
  end

  context "redirecting routes for an artefact" do
    should "redirect all defined prefix routes" do
      requests = [
        stub_redirect_registration("/foo", "prefix", "/new", "permanent"),
        stub_redirect_registration("/bar", "prefix", "/new", "permanent"),
        stub_redirect_registration("/baz", "prefix", "/new", "permanent")
      ]

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.redirect("/new")

      requests.each do |redirect_request, commit_request|
        assert_requested redirect_request
        assert_requested commit_request
      end
    end

    should "redirect all defined exact routes" do
      requests = [
        stub_redirect_registration("/foo.json", "exact", "/new", "permanent"),
        stub_redirect_registration("/bar", "exact", "/new", "permanent")
      ]

      @artefact.paths = ["/foo.json", "/bar"]
      @routable.redirect("/new")

      requests.each do |redirect_request, commit_request|
        assert_requested redirect_request
        assert_requested commit_request
      end
    end

    should "not commit when asked not to" do
      prefix_redirect_request, prefix_commit_request = stub_redirect_registration(
        "/foo", "prefix", "/new", "permanent")
      exact_redirect_request, exact_commit_request = stub_redirect_registration(
        "/bar", "exact", "/new", "permanent")

      @artefact.prefixes = ["/foo"]
      @artefact.paths = ["/bar"]
      @routable.redirect("/new", skip_commit: true)

      assert_requested prefix_redirect_request
      assert_requested exact_redirect_request
      assert_not_requested prefix_commit_request
      assert_not_requested exact_commit_request
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
        gone_request, commit_request = stub_redirect_registration(
          "/foo", "prefix", "/new", "permanent")

        gone_request.to_return(status: 404)

        @artefact.prefixes = ["/foo"]
        assert_nothing_raised do
          @routable.redirect("/new")
        end
      end

      should "continue to redirect other routes" do
        missing_redirect_request, _ = stub_redirect_registration(
          "/foo", "prefix", "/new", "permanent")
        missing_redirect_request.to_return(status: 404)

        redirect_request, commit_request = stub_redirect_registration(
          "/bar", "prefix", "/new", "permanent")

        @artefact.prefixes = ["/foo", "/bar"]
        @routable.redirect("/new")

        assert_requested redirect_request
        assert_requested commit_request
      end
    end
  end
end
