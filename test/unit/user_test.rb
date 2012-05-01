require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should convert to string" do
    user = User.new(:email => "user@example.com")
    assert_equal "user@example.com", user.to_s
  end

  test "should find existing user by oauth hash" do
    user = User.create!("uid" => "1234abcd")
    assert_equal user, User.find_for_gds_oauth("uid" => "1234abcd")
  end

  test "should create new user with oauth params" do
    auth_hash = {
      "uid" => "1234abcd",
      "extra" => {
        "user_hash" => {
          "uid"     => "1234abcd",
          "email"   => "user@example.com",
          "name"    => "Luther Blisset",
          "version" => 2
        }
      }
    }
    user = User.find_for_gds_oauth(auth_hash).reload
    assert_equal "1234abcd", user.uid
    assert_equal "user@example.com", user.email
    assert_equal "Luther Blisset", user.name
    assert_equal 2, user.version
  end
end
