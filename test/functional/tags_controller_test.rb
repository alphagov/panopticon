require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    user = create(:user, permissions: ['signin', 'manage_tags'])
    login_as(user)
  end

  context "POST create" do
    should "create a new tag" do
      tag_attrs = FactoryGirl.attributes_for(:tag, title: "Title of my new tag")

      post :create, tag: tag_attrs, format: :json

      assert_equal 201, response.status
      assert_equal "Title of my new tag", Tag.last.title
    end

    should "return appropriate response if the payload isn't valid" do
      invalid_attrs = { not_valid: "" }

      post :create, tag: invalid_attrs, format: :json

      assert_equal 422, response.status
    end
  end

  context "PUT update" do
    setup do
      @tag = create(:tag)
      @stub_atts = {'description' => 'Foo'}
    end

    should "update an existing tag" do
      Tag.any_instance.expects(:update_attributes).with(@stub_atts).returns(true)

      put :update, id: @tag.id, tag: @stub_atts, format: :json

      assert_equal 200, response.status
    end

    should "return an error if the tag_id parameter is present but differs from the existing value" do
      put :update, id: @tag.id, tag: @stub_atts.merge('tag_id' => 'something-else'), format: :json

      assert_equal 422, response.status
    end

    should "return an error if the parent_id parameter is present but differs from the existing value" do
      put :update, id: @tag.id, tag: @stub_atts.merge('parent_id' => 'something-else'), format: :json

      assert_equal 422, response.status
    end

    should "discard the tag_id parameter if present and matching the existing value" do
      Tag.any_instance.expects(:update_attributes).with(@stub_atts).returns(true)

      put :update, id: @tag.id, tag: @stub_atts.merge('tag_id' => @tag.tag_id), format: :json
    end

    should "discard the parent_id parameter if present and matching the existing value" do
      Tag.any_instance.expects(:update_attributes).with(@stub_atts).returns(true)

      put :update, id: @tag.id, tag: @stub_atts.merge('parent_id' => @tag.parent_id), format: :json
    end
  end

  context 'PUT publish' do
    should 'publish a draft tag' do
      tag = create(:draft_tag)
      Tag.any_instance.expects(:publish!).returns(true)

      put :publish, id: tag.id, format: :json

      assert response.ok?
    end

    should 'be cool with published tags' do
      tag = create(:live_tag)

      put :publish, id: tag.id, format: :json

      assert response.ok?
    end
  end

  context 'DELETE destroy' do
    should 'remove an empty tag' do
      tag = create(:draft_tag)

      delete :destroy, id: tag.id, format: :json

      assert response.ok?
      assert_raises Mongoid::Errors::DocumentNotFound do
        tag.reload
      end
    end

    should 'not remove tags with documents tagged to it' do
      tag = create(:draft_tag)
      artefact = create(:artefact, tag_ids: [tag.tag_id])

      delete :destroy, id: tag.id, format: :json

      assert_equal 409, response.status
      assert tag.reload
    end
  end
end
