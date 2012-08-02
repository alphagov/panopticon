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

        artefact1 = FactoryGirl.create(:artefact, tag_ids: ["crime"])
        artefact2 = FactoryGirl.create(:artefact, tag_ids: ["education"])

        get :index, section: "crime"
        assert_select "tbody tr", count: 1
        assert_select "tbody tr td", /crime/
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
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_id => 1, :primary_section => 'crime'
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal artefact.section, parsed['section']
      end

      should "return 404 if the artefact's not found" do
        get :show, id: 'bad-slug', format: :json
        assert_equal 404, response.code.to_i
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

      should "Update our primary section and ensure it persists into sections" do
        @tags = FactoryGirl.create_list(:tag, 3)
        artefact = Artefact.create!(:slug => 'whatever', :kind => 'guide',
                                    :owning_app => 'publisher', :name => 'Whatever', :need_id => 1,
                                    :tag_ids => [@tags[0].tag_id, @tags[1].tag_id])
        put :update, :id => artefact.id, :primary_section => @tags[2].tag_id
        artefact.reload

        assert_equal @tags[2].tag_id, artefact.primary_section
        assert_equal [@tags[2].tag_id, @tags[0].tag_id, @tags[1].tag_id], artefact.sections
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

  end
end
