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

  should 'delete an archived artefact from the router' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:delete)

    artefact = build(:archived_artefact)
    assert artefact.save
  end
end
