require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should "use a custom collection name for users" do
    assert_equal "panopticon_users", User.collection_name
  end
end
