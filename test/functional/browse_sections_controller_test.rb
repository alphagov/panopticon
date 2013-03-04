require 'test_helper'

class BrowseSectionsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET index" do
    setup do
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "a/1", title: "1", parent_id: "a")
    end

    should "list browse sections" do
      get :index
      assert_select "tbody tr", 2
    end
  end
end
