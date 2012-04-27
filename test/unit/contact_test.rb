require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test "should store multiple phone numbers" do
    phone_numbers = ["0113 496 0123", "028 9018 1337"]
    contact = Contact.create!(
      name: "Name", phone_numbers: phone_numbers,
      contactotron_id: 1
    )
    assert_equal phone_numbers, contact.reload.phone_numbers
  end
end
