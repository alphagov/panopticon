require 'test_helper'

class UpdateRouterObserverTest < ActiveSupport::TestCase
  setup { Artefact.observers.disable :update_search_observer }
  teardown { Artefact.observers.enable :update_search_observer }

  should 'submit a live artefact' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:submit)

    artefact = build(:live_artefact)
    assert artefact.save
  end

  should 'submit an archived artefact' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:submit)

    artefact = build(:archived_artefact)
    assert artefact.save
  end

  should 'submit a draft artefact' do
    mock_routable_artefact = mock("RoutableArtefact")
    RoutableArtefact.stubs(:new).returns(mock_routable_artefact)

    mock_routable_artefact.expects(:submit)

    artefact = build(:draft_artefact)
    assert artefact.save
  end
end
