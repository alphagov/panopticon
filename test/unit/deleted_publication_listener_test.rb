require "test_helper"
require "deleted_publication_listener"

class DeletedPublicationListenerTest < ActiveSupport::TestCase
  def mock_messenger
    mock("messenger").tap { |messenger|
      messenger.stubs(:join)
      messenger.stubs(:when)
    }
  end

  test "should destroy artefact when publication is deleted" do
    message = {"panopticon_id" => 1234}

    messenger = mock_messenger
    messenger.expects(:when).with("publisher", "*", "destroyed").yields(message)

    artefact = Artefact.new
    artefact.expects(:destroy)
    Artefact.expects(:find).with(1234).returns(artefact)

    DeletedPublicationListener.new(messenger, stub_everything).listen
  end
end

