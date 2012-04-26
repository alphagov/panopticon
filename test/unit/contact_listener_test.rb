require "test_helper"
require "contact_listener"

class ContactListenerTest < ActiveSupport::TestCase
  def mock_messenger
    mock("messenger").tap { |messenger|
      messenger.stubs(:join)
      messenger.stubs(:when)
    }
  end

  test "should create a contact" do
    message = {"id" => 1234}

    messenger = mock_messenger
    messenger.expects(:when).with("contactotron", "*", "created").yields(message)

    contact = mock("contact")
    contact.expects(:update_from_contactotron)
    Contact.expects(:find_or_initialize_by_contactotron_id).with(1234).returns(contact)

    ContactListener.new(messenger, stub_everything).listen
  end

  test "should update a contact" do
    message = {"id" => 1234}

    messenger = mock_messenger
    messenger.expects(:when).with("contactotron", "*", "updated").yields(message)

    contact = mock("contact")
    contact.expects(:update_from_contactotron)
    Contact.expects(:find_or_initialize_by_contactotron_id).with(1234).returns(contact)

    ContactListener.new(messenger, stub_everything).listen
  end
end
