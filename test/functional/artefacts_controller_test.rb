require 'test_helper'

class ArtefactsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "accept HTML" do
    context "GET show" do
      should "redirect to publisher when publisher is the owning app" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_id => 1
        get :show, id: artefact.to_param

        assert_redirected_to Plek.current.find('publisher') + "/admin/publications/#{artefact.id}"
      end
    end

    context "GET index" do
      should "should filter by section" do
        tag1 = FactoryGirl.create(:tag, tag_id: "crime", title: "Crime", tag_type: "section")
        tag2 = FactoryGirl.create(:tag, tag_id: "education", title: "Education", tag_type: "section")

        artefact1 = FactoryGirl.create(:artefact, sections: ["crime"])
        artefact2 = FactoryGirl.create(:artefact, sections: ["education"])

        get :index, section: "crime"
        assert_select "tbody tr", count: 1
        assert_select "tbody tr td", /crime/i
        assert_select "tbody tr td", artefact1.name
      end
    end

  end

  context "accept JSON" do
    context "POST /artefacts" do

      should "create a new artefact" do
        assert_difference "Artefact.count" do
          post :create, format: "json", :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :rendering_app => "frontend", :name => 'Whatever', :need_id => 1
        end
        artefact = Artefact.order_by([[:id, :desc]]).last
        assert_equal "whatever", artefact.slug
        assert_equal "guide", artefact.kind
        assert_equal "publisher", artefact.owning_app
        assert_equal "frontend", artefact.rendering_app
        assert_equal "Whatever", artefact.name
      end

      should "respond with JSON representing the new artefact" do
        post :create, format: "json", :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :rendering_app => 'frontend', :name => 'Whatever', :need_id => 1
        parsed = JSON.parse(response.body)
        assert_equal "publisher", parsed["owning_app"]
        assert_equal "frontend", parsed["rendering_app"]
        assert_equal "guide", parsed["kind"]
        assert_equal "whatever", parsed["slug"]
        assert_equal "Whatever", parsed["name"]
        assert parsed["id"].present?
      end

      should "record a create action on the artefact with the current user" do
        post(
          :create,
          format: "json",
          :slug => 'whatever',
          :kind => 'guide',
          :owning_app => 'publisher',
          :rendering_app => 'frontend',
          :name => 'Whatever',
          :need_id => 1
        )
        parsed = JSON.parse(response.body)
        artefact_id = parsed["id"]
        artefact = Artefact.find(artefact_id)
        assert_equal 1, artefact.actions.size
        assert_equal "create", artefact.actions.first.action_type
        assert_equal stub_user, artefact.actions.first.user
      end
    end

    context "GET /artefacts/:id" do
      should "Output json" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_id => 1
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal artefact.id.to_s, parsed['id']
        assert_equal artefact.name, parsed['name']
        assert_equal artefact.slug, parsed['slug']
        assert_equal artefact.kind, parsed['kind']
        assert_equal artefact.owning_app, parsed['owning_app']
      end

      should "Include section ID" do
        TagRepository.put :tag_id => 'crime', :tag_type => 'section', :title => 'Crime'
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_id => 1
        artefact.sections = ['crime']
        artefact.save!
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal artefact.section, parsed['section']
      end

      should "return 404 if the artefact's not found" do
        get :show, id: 'bad-slug', format: :json
        assert_equal 404, response.code.to_i
      end

      context "GET /artefacts/:id/edit" do
        should "Include history" do
          # Create and update the artefact to set up some actions
          artefact = Artefact.create!(
            :slug => 'whatever',
            :kind => 'guide',
            :owning_app => 'publisher',
            :name => 'Whatever',
            :need_id => 1,
          )
          artefact.update_attributes_as stub_user, name: "Changed"

          get :edit, id: artefact.id, format: :html

          # Check the actions: note reverse order
          actions = assigns["actions"]
          assert_equal ["update", "create"], actions.map(&:action_type)
          assert_equal [false, true], actions.map(&:initial?)
        end
      end

    end

    context "PUT /artefacts/:id" do

      should "Update existing artefact" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :rendering_app => 'frontend', :name => 'Whatever', :need_id => 1

        assert_difference "Artefact.count", 0 do
          put :update, id: artefact.id, format: :json, name: "Changed"
        end

        assert_response :success
        assert_equal "Changed", artefact.reload.name
      end

      should "Record the action and responsible user" do
        artefact = Artefact.create!(
          :slug => 'whatever',
          :kind => 'guide',
          :owning_app => 'publisher',
          :rendering_app => 'frontend',
          :name => 'Whatever',
          :need_id => 1
        )

        put :update, id: artefact.id, format: :json, name: "Changed"
        assert_response :success

        artefact.reload
        assert_equal stub_user, artefact.actions.last.user
      end

      should "Not record the user for API requests" do
        login_as GDS::SSO::ApiUser.new
        artefact = Artefact.create!(
          :slug => 'whatever',
          :kind => 'guide',
          :owning_app => 'publisher',
          :rendering_app => 'frontend',
          :name => 'Whatever',
          :need_id => 1
        )

        put :update, id: artefact.id, format: :json, name: "Changed"
        assert_response :success

        artefact.reload
        assert_equal nil, artefact.actions.last.user
      end


      should "Update our primary section and ensure it persists into sections" do
        tag1 = FactoryGirl.create(:tag, tag_id: "crime", title: "Crime", tag_type: "section")
        tag2 = FactoryGirl.create(:tag, tag_id: "education", title: "Education", tag_type: "section")

        artefact = Artefact.create!(:slug => 'whatever', :kind => 'guide',
                                    :owning_app => 'publisher', :name => 'Whatever', :need_id => 1)
        artefact.sections = [tag1.tag_id]
        artefact.save!
        put :update, :id => artefact.id, :artefact => {:primary_section => tag2.tag_id}

        artefact.reload
        assert_equal tag2.tag_id, artefact.primary_section.tag_id
        assert_equal [tag2.tag_id, tag1.tag_id], artefact.sections.map(&:tag_id)
      end

      should "Reject JSON requests to update an artefact's owning app" do
        artefact = Artefact.create!(
          slug: "whatever",
          kind: "guide",
          owning_app: "publisher",
          name: "Whatever",
          need_id: 1
        )
        put :update, id: artefact.id, "CONTENT_TYPE" => "application/json", owning_app: 'smart-answers'
        assert_equal 409, response.status
        assert response.body.include? "publisher"
      end
    end

    context "DELETE /artefacts/:id" do
      setup do
        WebMock.stub_request(:delete, "http://router.cluster:8080/router/routes/whatever").
            to_return(:status => 200)
        WebMock.stub_request(:delete, "http://search.test.gov.uk/documents/%2Fwhatever").
            to_return(:status => 200)
      end

      should "mark an artefact as archived" do
        artefact = Artefact.create!(
          slug: "whatever",
          kind: "guide",
          owning_app: "publisher",
          name: "Whatever",
          need_id: 1
        )
        delete :destroy, id: artefact.id, "CONTENT_TYPE" => "application/json"
        assert_equal 200, response.status
        assert_equal "archived", artefact.reload.state
      end

      should "return a 404" do
        delete :destroy, id: "4567", "CONTENT_TYPE" => "application/json"
        assert_equal 404, response.status
      end
    end
  end
end
