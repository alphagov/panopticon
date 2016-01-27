require_relative '../integration_test_helper'

class UpdateTagsTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_with_permission('manage_tags')
  end

  context 'updating a tag' do
    context "updating an existing tag" do
      setup do
        @tag = create(:tag, tag_type: 'section', tag_id: 'tea', title: 'Tea')
      end

      should 'update an existing tag given valid parameters' do
        put tag_path(@tag), { title: 'Coffee', format: 'json' }

        assert_equal 200, response.status

        @tag.reload
        assert_equal 'Coffee', @tag.title
      end

      should 'return validation errors given invalid parameters' do
        put tag_path(@tag), { title: '', format: 'json' }
        body = JSON.parse(response.body)

        assert_equal 422, response.status
        assert_match /can't be blank/, body['errors']['title'].first

        @tag.reload
        assert_equal 'Tea', @tag.title
      end

      context 'fields which cannot be changed' do
        should 'return error when a change is requested to the tag_id' do
          put tag_path(@tag), { tag_id: 'foo', format: 'json' }
          body = JSON.parse(response.body)

          assert_equal 422, response.status
          assert_match "can't be changed", body['errors']['tag_id'].first
        end

        should 'return error when a change is requested to the parent_id' do
          put tag_path(@tag), { parent_id: 'foo', format: 'json' }
          body = JSON.parse(response.body)

          assert_equal 422, response.status
          assert_match "can't be changed", body['errors']['parent_id'].first
        end

        should 'return error when a change is requested to the tag_type' do
          put tag_path(@tag), { tag_type: 'foo', format: 'json' }
          body = JSON.parse(response.body)

          assert_equal 422, response.status
          assert_match "can't be changed", body['errors']['tag_type'].first
        end
      end
    end

    context "when an existing tag doesn't already exist" do
      setup do
        @params = {
          format: 'json',
          tag_id: 'driving',
          tag_type: 'section',
          title: 'Driving',
          description: 'All about driving',
        }
      end

      should 'return a 201 status' do
        put tag_path("section/driving"), @params
        assert_equal 201, response.status
      end

      should 'create a new draft tag with the given parameters' do
        put tag_path("section/driving"), @params

        tag = Tag.by_tag_id('driving', type: 'section', draft: true)
        assert tag.present?, "Failed to find driving section tag"

        assert_equal 'Driving', tag.title
        assert_equal 'All about driving', tag.description
        assert_equal nil, tag.parent_id
        assert_equal 'draft', tag.state
      end

      context "for a non-existent child of an existing parent" do
        setup do
          @parent = create(:tag, tag_type: 'section', tag_id: 'driving', title: 'Driving')
          @params[:tag_id] = 'driving/abroad'
          @params[:parent_id] = 'driving'
        end

        should "create a new draft child tag" do
          put tag_path("section/driving/abroad"), @params
          puts response.body

          tag = Tag.by_tag_id('driving/abroad', type: 'section', draft: true)
          assert tag.present?, "Failed to find driving/abroad section tag"

          assert_equal 'driving', tag.parent_id
          assert_equal 'draft', tag.state
        end
      end
    end
  end

  context "publishing a tag" do
    should 'publish a draft tag' do
      draft_tag = create(:draft_tag)
      post publish_tag_path(draft_tag), format: 'json'

      assert_equal 200, response.status
    end

    should 'return an error for requests to publish a live tag' do
      live_tag = create(:live_tag)
      post publish_tag_path(live_tag), format: 'json'

      assert_equal 200, response.status
    end
  end
end
