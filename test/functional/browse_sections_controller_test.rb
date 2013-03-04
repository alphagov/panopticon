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

  context "GET edit" do
    should "show the artefacts"
  end

  context "PUT update" do
    setup do
      login_as_user_with_permission
      @section = FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
    end

    should "update the section tag" do
      put :update, id: @section.id, section: { title: "Amore" }
      assert_equal "Amore", @section.reload.title
      assert_redirected_to browse_sections_path
      assert_match(/updated/i, flash[:notice])
    end

    should "rerender the form if invalid" do
      put :update, id: @section.id, section: { title: "" }
      assert_template :edit
      assert_match(/Failed to save/i, flash[:error])
    end

    should "prevent updates to the tag_id (slug)" do
      put :update, id: @section.id, section: { tag_id: "h4x0r" }
      assert_equal "a", @section.reload.tag_id
    end
  end
end
