require_relative '../../test_helper'

class UpdateRouterObserverTest < ActiveSupport::TestCase
  setup do
    stub_all_router_api_requests
    stub_all_rummager_requests
  end

  should 'not register a draft artefact with the router' do
    RoutableArtefact.expects(:new).never

    artefact = build(:draft_artefact)
    assert artefact.save
  end

  should 'submit a live artefact into the router' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:submit)

    artefact = build(:live_artefact)
    assert artefact.save
  end

  should 'mark an archived artefact as gone in the router' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:delete)

    artefact = build(:archived_artefact)
    assert artefact.save
  end

  should 'not delete an artefact owned by Whitehall from the router' do
    RoutableArtefact.expects(:new).never

    artefact = build(:archived_artefact, owning_app: 'whitehall')
    assert artefact.save
  end

  should 'add a redirect for an artefact if requested' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:redirect, "/new")

    artefact = build(:archived_artefact, redirect_url: "/new")
    assert artefact.save
  end

  should 'not redirect an artefact owned by Whitehall' do
    RoutableArtefact.expects(:new).never

    artefact = build(:archived_artefact,
                     owning_app: 'whitehall', 
                     redirect_url: "/new")
    assert artefact.save
  end
end
