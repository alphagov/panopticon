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

    should "group tags by their parents" do
      parent_1 = create(:tag, title: 'A')
      parent_2 = create(:tag, title: 'B')
      parent_3 = create(:tag, title: 'C')

      children_1 = create_list(:tag, 5, parent_id: parent_1.tag_id)
      children_2 = create_list(:tag, 5, parent_id: parent_2.tag_id)

      get :index

      groups = assigns(:parents)

      assert_equal 3, groups.size
      assert_equal [parent_1, parent_2, parent_3], groups.map {|parent, children| parent }

      assert_equal children_1.sort, groups[0].last.sort
      assert_equal children_2.sort, groups[1].last.sort
      assert_equal [], groups[2].last
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

  context "GET edit" do
    setup do
      @tag = create(:tag)
    end

    should "render the edit form given an existing tag" do
      get :edit, id: @tag.id

      assert response.ok?
      assert_template :edit
    end

    should "assign the tag to the template given an existing tag" do
      get :edit, id: @tag.id

      assert_equal @tag, assigns(:tag)
    end

    should "return a not found error if a tag doesn't exist" do
      get :edit, id: "foo"

      assert response.not_found?
    end
  end

  context "PUT update" do
    setup do
      @tag = create(:tag)
      @stub_atts = {'description' => 'Foo'}
    end

    should "update an existing tag" do
      Tag.any_instance.expects(:update_attributes).with(@stub_atts).returns(true)

      put :update, id: @tag.id, tag: @stub_atts
    end

    should "return a not found error if a tag doesn't exist" do
      put :update, id: "foo", tag: @stub_atts

      assert response.not_found?
    end

    should "redirect to the tags list on a successful update" do
      Tag.any_instance.expects(:update_attributes).returns(true)

      put :update, id: @tag.id, tag: @stub_atts

      assert_match /updated/, @controller.flash[:notice]
      assert_redirected_to tags_path
    end

    should "render the form when the update fails" do
      Tag.any_instance.expects(:update_attributes).returns(false)

      put :update, id: @tag.id, tag: @stub_atts

      assert response.ok?
      assert_template :edit
    end
  end

end
