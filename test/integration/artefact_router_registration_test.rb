require_relative "../integration_test_helper"

class ArtefactRouterRegistrationTest < ActionDispatch::IntegrationTest
  def artefact_details_hash(attrs = {})
    {
      :slug => "foo",
      :owning_app => "a-backend",
      :kind => "answer",
      :state => "draft",
      :name => "Foo",
      :description => "All about foo",
      :prefixes => ["/foo"],
    }.merge(attrs)
  end

  setup do
    stub_user
    stub_all_rummager_requests

    @router_api_base = Plek.current.find('router-api')
    @route_commit_request = WebMock.stub_request(:post, "#{@router_api_base}/routes/commit").to_return(:status => 200)
    @backend_request = WebMock.stub_request(:put, "#{@router_api_base}/backends/a-backend").to_return(:status => 200)
    @route_add_request = WebMock.stub_request(:put, "#{@router_api_base}/routes").
      with(:body => {"route" => hash_including("incoming_path" => "/foo", "route_type" => "prefix")}).
      to_return(:status => 201)
  end

  context "creating an artefact" do
    should "not register with the router when creating a draft artefact" do
      put_json "/artefacts/foo.json", artefact_details_hash(:state => "draft")
      assert_equal 201, response.code.to_i

      assert_not_requested @backend_request
      assert_not_requested @route_add_request
      assert_not_requested @route_commit_request
    end

    should "register with the router when creating a live artefact" do
      put_json "/artefacts/foo.json", artefact_details_hash(:state => "live")
      assert_equal 201, response.code.to_i

      assert_requested @backend_request
      assert_requested @route_add_request
      assert_requested @route_commit_request
    end
  end

  context "updating an artefact" do
    setup do
      FactoryGirl.create(:artefact, :slug => "foo", :owning_app => 'a-backend')
    end

    should "not register with the router when the updated artefact is in draft" do
      put_json "/artefacts/foo.json", artefact_details_hash(:state => "draft")
      assert_equal 200, response.code.to_i

      assert_not_requested @backend_request
      assert_not_requested @route_add_request
      assert_not_requested @route_commit_request
    end

    should "register with the router when the updated artefact is live" do
      put_json "/artefacts/foo.json", artefact_details_hash(:state => "live")
      assert_equal 200, response.code.to_i

      assert_requested @backend_request
      assert_requested @route_add_request
      assert_requested @route_commit_request
    end

    should "register the correct prefix and exact paths with the router" do
      r2 = WebMock.stub_request(:put, "#{@router_api_base}/routes").
        with(:body => {"route" => hash_including("incoming_path" => "/bar", "route_type" => "prefix")}).
        to_return(:status => 201)
      r3 = WebMock.stub_request(:put, "#{@router_api_base}/routes").
        with(:body => {"route" => hash_including("incoming_path" => "/foo.json", "route_type" => "exact")}).
        to_return(:status => 201)

      put_json "/artefacts/foo.json", artefact_details_hash(:state => "live", :paths => ["/foo.json"], :prefixes => ["/foo", "/bar"])
      assert_equal 200, response.code.to_i

      assert_requested @backend_request
      assert_requested @route_add_request
      assert_requested r2
      assert_requested r3
      assert_requested @route_commit_request, :times => 1
    end

    should "delete routes in the router then the updated artefact is archived" do
      delete_request = WebMock.stub_request(:delete, "#{@router_api_base}/routes").
        with(:query => {"incoming_path" => "/foo", "route_type" => "prefix"}).
        to_return(:status => 200)

      put_json "/artefacts/foo.json", artefact_details_hash(:state => "archived")
      assert_equal 200, response.code.to_i

      assert_not_requested @backend_request
      assert_requested delete_request
      assert_requested @route_commit_request
    end

    should "not blow up when deleting routes if the routes dont exist" do
      delete_request = WebMock.stub_request(:delete, "#{@router_api_base}/routes").
        with(:query => {"incoming_path" => "/foo", "route_type" => "prefix"}).
        to_return(:status => 404)

      put_json "/artefacts/foo.json", artefact_details_hash(:state => "archived")
      assert_equal 200, response.code.to_i

      assert_requested delete_request
    end
  end
end
