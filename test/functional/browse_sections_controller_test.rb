require 'test_helper'

class BrowseSectionsControllerTest < ActionController::TestCase

  def login_as_user_with_permission
    u = stub_user
    u.permissions = u.permissions + ["Browse section admin"]
    u.save!
    login_as(u)
  end

  context "access control" do
    should "only grant access to users with permission" do
      login_as_stub_user
      get :index
      assert_response 403
    end
  end

  context "GET index" do
    setup do
      login_as_user_with_permission
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "a/1", title: "1", parent_id: "a")
    end

    should "list browse sections" do
      get :index
      assert_select "tbody tr", 2
    end
  end
end
