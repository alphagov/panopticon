require 'test_helper'

class UpdateRouterCallbackTest < ActiveSupport::TestCase
  setup { Artefact.any_instance.stubs(:update_search) }

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
