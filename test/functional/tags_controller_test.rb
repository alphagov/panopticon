require 'test_helper'

class TagsControllerTest < ActionController::TestCase

  setup do
    login_as_stub_user
  end

  context "GET index" do
    should "render successfully the index template" do
      get :index

      assert response.ok?
      assert_template :index
    end

    should "assign tags to the template" do
      create(:tag)
      get :index

      assert_equal 1, assigns(:tags).count
      assert assigns(:tags).first.is_a?(Tag)
    end
  end

  context "GET new" do
    should "render the new template successfully" do
      get :new

      assert response.ok?
      assert_template :new
    end

    should "assign a new tag to the form template" do
      get :new

      assert assigns(:tag).is_a?(Tag)
      assert assigns(:tag).new_record?
    end
  end

  context "POST create" do
    setup do
      @stub_atts = {'foo' => 'bar'}
    end

    should "build and save a new tag" do
      stub_tag = stub("Tag")
      Tag.expects(:new).with(@stub_atts).returns(stub_tag)
      stub_tag.expects(:save).returns(true)

      post :create, tag: @stub_atts
    end

    should "redirect to the tags list on a successful save" do
      Tag.any_instance.expects(:save).returns(true)
      post :create, tag: @stub_atts

      assert_match /created/, @controller.flash[:notice] 
      assert_redirected_to tags_path
    end

    should "render the form when the save fails" do
      Tag.any_instance.expects(:save).returns(false)
      post :create, tag: @stub_atts

      assert response.ok?
      assert_template :new
    end
  end

end
