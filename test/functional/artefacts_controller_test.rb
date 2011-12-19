require 'test_helper'

class ArtefactsControllerTest < ActionController::TestCase
  context "accept HTML" do
    context "GET show" do
      should "redirect to publisher" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever'
        get :show, id: artefact.to_param

        assert_redirected_to Plek.current.find('publisher') + "/admin/publications/#{artefact.id}"
      end
    end
  end
  
  context "accept JSON" do
    context "POST /artefacts" do
      
      should "create a new artefact" do
        assert_difference "Artefact.count" do
          post :create, format: "json", :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever'
        end
        artefact = Artefact.order("id desc").last
        assert_equal "whatever", artefact.slug
        assert_equal "guide", artefact.kind
        assert_equal "publisher", artefact.owning_app
        assert_equal "Whatever", artefact.name
      end

      should "respond with JSON representing the new artefact" do
        post :create, format: "json", :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever'
        parsed = JSON.parse(response.body)
        assert_equal "publisher", parsed["owning_app"]
        assert_equal "guide", parsed["kind"]
        assert_equal "whatever", parsed["slug"]
        assert_equal "Whatever", parsed["name"]
        assert parsed["id"].present?
      end
    end

    context "GET /artefacts/:id" do
      should "Output json" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever'
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)
        
        assert_equal artefact.id, parsed['id']
        assert_equal artefact.name, parsed['name']
        assert_equal artefact.slug, parsed['slug']
        assert_equal artefact.kind, parsed['kind']
        assert_equal artefact.owning_app, parsed['owning_app']
      end
    end

    context "PUT /artefacts/:id" do
      
      should "Update existing artefact" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever'
      
        assert_difference "Artefact.count", 0 do
          put :update, id: artefact.id, format: :json, name: "Changed"
        end
      
        assert_equal "Changed", artefact.reload.name
        assert_response :success
      end
    end
    
  end
end
