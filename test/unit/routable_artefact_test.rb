require 'test_helper'
require 'gds_api/test_helpers/router'

class RoutableArtefactTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Router

  context "submitting a live artefact" do
    context "for a non-whitelisted artefact" do
      setup do
        stub_artefact_callbacks
        @artefact = FactoryGirl.create(:whitehall_live_artefact,
                                       owning_app: ["whitehall", SecureRandom.hex].sample,
                                       paths: ["/foo"])
        @routable = RoutableArtefact.new(@artefact)
      end

      should "not register the route" do
        @routable.expects(:register).times(0)
        @routable.expects(:commit).times(0)

        @routable.submit
      end
    end

    context "for a artefact owned by a whitelisted application" do
      setup do
        stub_artefact_callbacks
        @artefact = FactoryGirl.create(:live_artefact,
                                       owning_app: "publisher",
                                       paths: ["/foo"])
        @routable = RoutableArtefact.new(@artefact)
      end

      should "register the route" do
        @routable.expects(:register)
        @routable.expects(:commit)

        @routable.submit
      end
    end
  end

  context "registering routes for an artefact" do
    setup do
      @artefact = FactoryGirl.create(:artefact, owning_app: "publisher")
      @routable = RoutableArtefact.new(@artefact)
      stub_all_router_registration
    end

    should "add all defined prefix routes" do
      requests = [
        stub_route_registration("/foo", "prefix", "publisher"),
        stub_route_registration("/bar", "prefix", "publisher"),
        stub_route_registration("/baz", "prefix", "publisher")
      ]

      @artefact.prefixes = ["/foo", "/bar", "/baz"]
      @routable.register

      requests.each do |route_request, _commit_request|
        assert_requested route_request
      end
    end

    should "add all defined exact routes" do
      requests = [
        stub_route_registration("/foo.json", "exact", "publisher"),
        stub_route_registration("/bar", "exact", "publisher")
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
end
