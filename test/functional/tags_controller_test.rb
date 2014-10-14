require 'test_helper'

class TagsControllerTest < ActionController::TestCase

  def login_as_user_with_permission
    user = create(:user, permissions: ['signin', 'manage_tags'])
    login_as(user)
  end

  setup do
    login_as_user_with_permission
  end

  should "only grant access to users with permission" do
    login_as_stub_user
    get :index

    assert_response 403
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

    should "set the tag type when provided in the url" do
      get :new, type: "section"

      assert_equal "section", assigns(:tag).tag_type
    end

    should "set the tag type and parent id when provided in the url" do
      get :new, type: "section", parent_id: "business"

      assert_equal "section", assigns(:tag).tag_type
      assert_equal "business", assigns(:tag).parent_id
    end
  end

  context "POST create" do
    setup do
      @stub_atts = {'foo' => 'bar'}
    end

    should "build and save a new tag" do
      stub_tag = stub("Tag", parent_id: nil)
      Tag.expects(:new).with(@stub_atts).returns(stub_tag)
      stub_tag.expects(:save).returns(true)

      post :create, tag: @stub_atts
    end

    should "redirect to the tags list on a successful save" do
      Tag.any_instance.expects(:save).returns(true)
      post :create, tag: @stub_atts

      assert_match /created/, @controller.flash[:success]
      assert_redirected_to tags_path
    end

    should "render the form when the save fails" do
      Tag.any_instance.expects(:save).returns(false)
      post :create, tag: @stub_atts

      assert response.ok?
      assert_template :new
    end

    should "prepend the parent to a tag id when a parent is present given a html request" do
      Tag.any_instance.expects(:save).returns(true)

      post :create, format: :html,
                    tag: @stub_atts.merge('tag_id' => 'families',
                                          'parent_id' => 'benefits')

      assert_equal 'benefits/families', assigns(:tag).tag_id
    end

    should 'not prepend the parent_id to the tag_id given a json request' do
      Tag.any_instance.expects(:save).returns(true)

      post :create, format: :json,
                    tag: @stub_atts.merge('tag_id' => 'benefits/families',
                                          'parent_id' => 'benefits')

      assert_equal 'benefits/families', assigns(:tag).tag_id
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

    should "return an error if the tag_id parameter is present but differs from the existing value" do
      put :update, id: @tag.id, tag: @stub_atts.merge('tag_id' => 'something-else')

      assert_equal 422, response.status
    end

    should "return an error if the parent_id parameter is present but differs from the existing value" do
      put :update, id: @tag.id, tag: @stub_atts.merge('parent_id' => 'something-else')

      assert_equal 422, response.status
    end

    should "discard the tag_id parameter if present and matching the existing value" do
      Tag.any_instance.expects(:update_attributes).with(@stub_atts).returns(true)

      put :update, id: @tag.id, tag: @stub_atts.merge('tag_id' => @tag.tag_id)
    end

    should "discard the parent_id parameter if present and matching the existing value" do
      Tag.any_instance.expects(:update_attributes).with(@stub_atts).returns(true)

      put :update, id: @tag.id, tag: @stub_atts.merge('parent_id' => @tag.parent_id)
    end

    should "return a not found error if a tag doesn't exist" do
      put :update, id: "foo", tag: @stub_atts

      assert response.not_found?
    end

    should "redirect to the tags list on a successful update" do
      Tag.any_instance.expects(:update_attributes).returns(true)

      put :update, id: @tag.id, tag: @stub_atts

      assert_match /updated/, @controller.flash[:success]
      assert_redirected_to tags_path
    end

    should "render the form when the update fails" do
      Tag.any_instance.expects(:update_attributes).returns(false)

      put :update, id: @tag.id, tag: @stub_atts

      assert response.ok?
      assert_template :edit
    end
  end

  context 'PUT publish' do
    should 'publish a draft tag' do
      tag = create(:draft_tag)
      Tag.any_instance.expects(:publish!).returns(true)

      put :publish, id: tag.id

      assert_match /published/, @controller.flash[:success]
      assert_redirected_to edit_tag_path(tag)
    end

    should 'redirect with an error for a live tag' do
      tag = create(:live_tag)

      put :publish, id: tag.id

      assert_match /already live/, @controller.flash[:error]
      assert_redirected_to edit_tag_path(tag)
    end
  end

end
