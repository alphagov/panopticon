require 'test_helper'
require 'gds_api/test_helpers/router'

class ArtefactsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET search_relatable_items" do
    should "return relatable item names prefixed with mainstream or whitehall in json format" do
      relatable_artefacts = [FactoryGirl.create(:artefact, name: "Benefits calculator", slug: "benefits-calc", owning_app: "whitehall"),
                              FactoryGirl.create(:artefact, name: "Child tax benefits", slug: "child-tax", owning_app: "publisher")]

      get :search_relatable_items, title_substring: "bene", format: :json

      expected_response = { artefacts: [
                            { id: "benefits-calc",
                              text: "[Whitehall] Benefits calculator" }],
                            total: 1 }
      assert_equal expected_response.to_json, response.body
    end
  end

  context "accept HTML" do
    context "GET show" do
      should "redirect to publisher when publisher is the owning app" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_ids => ['100001']
        get :show, id: artefact.to_param

        assert_redirected_to Plek.current.find('publisher') + "/admin/publications/#{artefact.id}"
      end
    end

    context "GET index" do
      setup do
        FactoryGirl.create_list(:artefact, 10)
      end

      context "with filters" do
        setup do
          # these tests are only concerned with the controller's filtering behaviour:
          # specifically this is testing that the correct scopes are called on the Artefact object
          # which we're going to stub out here
          @scope = stub("Scope")
          @controller.expects(:artefact_scope).returns(@scope)

          # stub out the extra calls which get made on the scope object
          @scope.stubs(:order_by => @scope, :page => @scope, :per => @scope, :where => @scope, :without => @scope)
          @scope.stubs(:not_owned_by).with('panopticon').returns(@scope)

          # we aren't testing the template behaviour here, so don't try and render the template
          @controller.stubs(:render)
        end

        should "apply the tag scope for section filters" do
          @scope.expects(:with_parent_tag).with(:section, "driving").returns(@scope)

          get :index, section: "driving"
        end

        should "apply the tag scope for specialist sector filters" do
          @scope.expects(:with_parent_tag).with(:specialist_sector, "oil-and-gas").returns(@scope)

          get :index, specialist_sector: "oil-and-gas"
        end

        should "apply the kind scope" do
          @scope.expects(:of_kind).with("answer").returns(@scope)

          get :index, kind: "answer"
        end

        should "apply the owned_by scope" do
          @scope.expects(:owned_by).with("calculators").returns(@scope)

          get :index, owned_by: "calculators"
        end

        should "restricted owned_by to not include panopticon" do
          @scope.expects(:not_owned_by).with("panopticon").returns(@scope)

          get :index
        end

        should "allow owned_by to include panopticon if explicit" do
          # Most tests in this context expect :not_owned_by to be called, so we
          # stub this method in the setup block. Here we need to explicitly
          # unstub it for the .never expectation to work (thanks mocha!)
          @scope.unstub(:not_owned_by)

          @scope.expects(:owned_by).with("panopticon").returns(@scope)
          @scope.expects(:not_owned_by).never

          get :index, owned_by: 'panopticon'
        end

        should "not apply the kind scope when it's not a valid kind" do
          @scope.expects(:of_kind).never

          get :index, kind: "superfluous-campaign"
        end

        should "apply the state scope" do
          @scope.expects(:in_state).with("live").returns(@scope)

          get :index, state: "live"
        end

        should "not apply the state scope when it's not a valid state" do
          @scope.expects(:in_state).never

          get :index, state: "something"
        end

        should "apply the search scope" do
          @scope.expects(:matching_query).with("foo").returns(@scope)

          get :index, search: "foo"
        end

        should "combine multiple scopes together" do
          @scope.expects(:with_parent_tag).with(:section, "driving").returns(@scope)
          @scope.expects(:with_parent_tag).with(:specialist_sector, "oil-and-gas").returns(@scope)
          @scope.expects(:of_kind).with("answer").returns(@scope)
          @scope.expects(:in_state).with("live").returns(@scope)
          @scope.expects(:matching_query).with("foo").returns(@scope)

          get :index, section: "driving", specialist_sector: "oil-and-gas", kind: "answer", state: "live", search: "foo"
        end
      end

      should "fetch a collection of artefacts" do
        get :index

        assert_equal 10, assigns(:artefacts).size
        assigns(:artefacts).each do |artefact|
          assert artefact.is_a?(Artefact)
        end
      end

      should "render the index view template" do
        get :index

        assert_template "index"
      end

      context "minimal view" do
        setup do
          get :index, format: :json, minimal: 1
          @json = JSON.parse(response.body)
        end

        should "include a list of results" do
          assert_equal 10, @json.count
        end

        should "include artefact names" do
          @json.each do |artefact_json|
            assert artefact_json["name"].present?
          end
        end

        should "not include tag information" do
          @json.each do |artefact_json|
            refute artefact_json.include? "tag_ids"
            refute artefact_json.include? "tags"
          end
        end
      end
    end

    context "GET new" do

      should "render only the non-whitehall link as active" do
        get :new
        assert_select "li[class~=active] a[href=/artefacts/new]"
        assert_select "li[class~=active] a[href=/artefacts/new?owning_app=whitehall]", false
      end

      context "whitehall is the owning_app" do
        should "render the whitehall variant of the form" do
          get :new, owning_app: "whitehall"
          assert_template :whitehall_form
        end

        should "display only the whitehall link as active" do
          get :new, owning_app: "whitehall"
          assert_select "li[class~=active] a[href=/artefacts/new]", false
          assert_select "li[class~=active] a[href=/artefacts/new?owning_app=whitehall]"
        end
      end
    end

    context "POST create" do
      context "invalid artefact" do
        should "rerender the form" do
          Artefact.any_instance.stubs(:need)
          post :create, :artefact => { :slug => 'not/valid', :owning_app => 'smart-answers', :kind => 'smart-answer', :name => 'Whatever', :need_ids => '100001' }
        end

        should "not blow up if not given a slug" do
          # simulate the error that url-arbiter would return if it was called
          url_arbiter_returns_validation_error_for("/", "path" => ["can't be blank"])

          post :create, :artefact => {
            :owning_app => 'smart-answers',
            :slug => '',
            :kind => 'smart-answer',
            :name => 'Whatever',
            :need_ids => '100001'
          }

          assert_template('new')
          assert_equal ["can't be blank"], assigns[:artefact].errors[:slug]
        end
      end

      should "redirect to GET edit" do
        Artefact.any_instance.stubs(:id).returns("abc")
        post :create, :artefact => { :owning_app => 'smart-answers', :slug => 'whatever', :kind => 'smart-answer', :name => 'Whatever', :need_ids => '100001' }

        assert_redirected_to "/artefacts/abc/edit"
      end

      context "publisher artefact" do
        setup do
          Artefact.any_instance.stubs(:id).returns("abc")
        end

        def valid_artefact_params
          { :owning_app => 'publisher',
            :slug => 'whatever',
            :kind => 'guide',
            :name => 'Whatever',
            :need_ids => "100001" }
        end

        should "redirect to publisher" do
          post :create, artefact: valid_artefact_params

          assert_redirected_to Plek.current.find('publisher') + "/admin/publications/abc"
        end

        should "redirect to edit page when requested" do
          post :create, artefact: valid_artefact_params, commit: "Save and continue editing"

          assert_redirected_to "/artefacts/abc/edit"
        end
      end

      should "split need_ids if they come in as comma-separated values" do
        post :create, artefact: valid_artefact_params.merge(need_ids: "331312,333123")

        assert_equal ["331312", "333123"], @controller.params[:artefact][:need_ids]
      end

      should "split related_artefact_slugs as they come in as comma-separated values" do
        post :create, artefact: { related_artefact_slugs: "benefits-calculators, \nchild-tax-credit" }

        assert_equal ["benefits-calculators", "child-tax-credit"], @controller.params[:artefact][:related_artefact_slugs]
      end
    end

    context "GET edit" do
      context "whitehall is the owning_app" do
        should "render the whitehall variant of the form" do
          artefact = FactoryGirl.create(:artefact, owning_app: "whitehall")
          get :edit, id: artefact.id
          assert_template :whitehall_form
        end
      end

      should "assign list of sections" do
        FactoryGirl.create(:live_tag, :tag_type => 'section', :tag_id => 'kablooey', :title => 'Kablooey')
        FactoryGirl.create(:live_tag, :tag_type => 'section', :tag_id => 'fooey', :title => 'Fooey')
        FactoryGirl.create(:live_tag, :tag_type => 'section', :tag_id => 'gooey', :title => 'Gooey')
        FactoryGirl.create(:live_tag, :tag_type => 'legacy_source', :tag_id => 'businesslink', :title => 'Business Link')

        artefact = FactoryGirl.create(:artefact)

        get :edit, id: artefact.id, format: :html

        assert_equal ['fooey', 'gooey', 'kablooey'], assigns["tag_collection"].map(&:tag_id)
      end
    end

    context "GET history" do
      should "Include history" do
        # Create and update the artefact to set up some actions
        artefact = Artefact.create!(
          :slug => 'whatever',
          :kind => 'guide',
          :owning_app => 'publisher',
          :name => 'Whatever',
          :need_ids => ['100001'],
        )
        artefact.update_attributes_as stub_user, name: "Changed"

        get :history, id: artefact.id, format: :html

        # Check the actions: note reverse order
        actions = assigns["actions"]
        assert_equal ["update", "create"], actions.map(&:action_type)
        assert_equal [false, true], actions.map(&:initial?)
      end
    end

    context "PUT update" do
      context "invalid artefact" do
        should "be invalid with an empty title" do
          artefact1 = FactoryGirl.create(:artefact)
          artefact1.name = ""
          put :update, id: artefact1.id, artefact: { name: "" }
          assert_template :edit
        end
      end

      should "redirect to GET edit" do
        artefact = FactoryGirl.create(:artefact, owning_app: "smart-answers", kind: "smart-answer")
        put :update, :id => artefact.id, :artefact => { :owning_app => 'smart-answers', :slug => 'whatever', :kind => 'smart-answer', :name => 'Whatever', :need_ids => '100001' }

        assert_redirected_to "/artefacts/#{artefact.id}/edit"
      end

      context "publisher is owning_app" do
        should "redirect to GET show (which then redirects to publisher)" do
          artefact = FactoryGirl.create(:artefact)
          put :update, :id => artefact.id, :artefact => { :owning_app => 'publisher', :slug => 'whatever', :kind => 'guide', :name => 'Whatever', :need_ids => '100001' }

          assert_redirected_to "/artefacts/#{artefact.id}"
        end
      end
    end
  end

  context "accept JSON" do
    context "POST /artefacts" do

      should "create a new artefact" do
        assert_difference "Artefact.count" do
          post :create, format: "json", :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :rendering_app => "frontend", :name => 'Whatever', :need_ids => ['100001']
        end
        artefact = Artefact.order_by([[:id, :desc]]).last
        assert_equal "whatever", artefact.slug
        assert_equal "guide", artefact.kind
        assert_equal "publisher", artefact.owning_app
        assert_equal "frontend", artefact.rendering_app
        assert_equal "Whatever", artefact.name
      end

      should "respond with JSON representing the new artefact" do
        post :create, format: "json", :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :rendering_app => 'frontend', :name => 'Whatever', :need_ids => ['100001']
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
          :need_ids => ['100001']
        )
        parsed = JSON.parse(response.body)
        artefact_id = parsed["id"]
        artefact = Artefact.find(artefact_id)
        assert_equal 1, artefact.actions.size
        assert_equal "create", artefact.actions.first.action_type
        assert_equal stub_user, artefact.actions.first.user
      end

      should "create an artefact of kind 'video' for the current user" do
        post :create, format: "json", slug: "welcome-to-the-world-of-tomorrow", kind: "video", owning_app: "publisher", rendering_app: "frontend", name: "Welcome to the world of Tomorrow!", need_ids: ['100001']

        parsed = JSON.parse(response.body)
        assert_equal "publisher", parsed["owning_app"]
        assert_equal "frontend", parsed["rendering_app"]
        assert_equal "video", parsed["kind"]
        assert_equal "welcome-to-the-world-of-tomorrow", parsed["slug"]
        assert_equal "Welcome to the world of Tomorrow!", parsed["name"]
        assert_equal true, parsed["id"].present?

        artefact_id = parsed["id"]
        artefact = Artefact.find(artefact_id)
        assert_equal 1, artefact.actions.size
        assert_equal "create", artefact.actions.first.action_type
        assert_equal stub_user, artefact.actions.first.user
      end
    end

    context "GET /artefacts/:id" do
      should "Output json" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_ids => ['100001']
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal artefact.id.to_s, parsed['id']
        assert_equal artefact.name, parsed['name']
        assert_equal artefact.slug, parsed['slug']
        assert_equal artefact.kind, parsed['kind']
        assert_equal artefact.owning_app, parsed['owning_app']
      end

      should "Output json for slug with slash in slug" do
        artefact = Artefact.create! :slug => 'done/whatever', :kind => 'answer', :owning_app => 'publisher', :name => 'Done Whatever', :need_ids => ['100001']
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal artefact.id.to_s, parsed['id']
        assert_equal artefact.name, parsed['name']
        assert_equal artefact.slug, parsed['slug']
      end

      should "Include section ID" do
        FactoryGirl.create(:live_tag, :tag_id => 'crime', :tag_type => 'section', :title => 'Crime')
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_ids => ['100001']
        artefact.sections = ['crime']
        artefact.save!
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal artefact.section, parsed['section']
      end

      should "Include tag_ids" do
        FactoryGirl.create(:live_tag, :tag_id => 'crime', :tag_type => 'section', :title => 'Crime')
        FactoryGirl.create(:live_tag, :tag_id => 'businesslink', :tag_type => 'legacy_source', :title => 'Business Link')
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :name => 'Whatever', :need_ids => ['100001']
        artefact.sections = ['crime']
        artefact.legacy_sources = ['businesslink']
        artefact.save!
        get :show, id: artefact.id, format: :json
        parsed = JSON.parse(response.body)

        assert_equal %w(businesslink crime), parsed['tag_ids'].sort
      end

      should "return 404 if the artefact's not found" do
        get :show, id: 'bad-slug', format: :json
        assert_equal 404, response.code.to_i
      end
    end

    context "PUT /artefacts/:id" do

      should "Update existing artefact" do
        artefact = Artefact.create! :slug => 'whatever', :kind => 'guide', :owning_app => 'publisher', :rendering_app => 'frontend', :name => 'Whatever', :need_ids => ['100001']

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
          :need_ids => ['100001']
        )

        put :update, id: artefact.id, format: :json, name: "Changed"
        assert_response :success

        artefact.reload
        assert_equal stub_user, artefact.actions.last.user
      end

      should "Update our primary section and ensure it persists into sections" do
        tag1 = FactoryGirl.create(:live_tag, tag_id: "crime", title: "Crime", tag_type: "section")
        tag2 = FactoryGirl.create(:live_tag, tag_id: "education", title: "Education", tag_type: "section")

        artefact = Artefact.create!(:slug => 'whatever', :kind => 'guide',
                                    :owning_app => 'publisher', :name => 'Whatever', :need_ids => ['100001'])
        artefact.sections = [tag1.tag_id]
        artefact.save!
        put :update, :id => artefact.id, :artefact => {:primary_section => tag2.tag_id}

        artefact.reload
        assert_equal tag2.tag_id, artefact.primary_section.tag_id
        assert_equal [tag2.tag_id, tag1.tag_id], artefact.sections.map(&:tag_id)
      end

      should "Update the specialist sectors and ensure it persists into tags" do
        tag1 = FactoryGirl.create(:live_tag, tag_id: "fizzy-drinks", title: "Fizzy drinks", tag_type: "specialist_sector")
        tag2 = FactoryGirl.create(:live_tag, tag_id: "confectionery", title: "Confectionery", tag_type: "specialist_sector")

        artefact = Artefact.new(:slug => 'a-history-of-chocolate', :kind => 'guide',
                                    :owning_app => 'publisher', :name => 'A history of chocolate', :need_ids => ['100001'])
        artefact.specialist_sectors = [tag1.tag_id]
        artefact.save!

        put :update, :id => artefact.id, :artefact => {:specialist_sectors => [tag1.tag_id, tag2.tag_id]}

        artefact.reload
        assert_equal [tag1.tag_id, tag2.tag_id], artefact.specialist_sectors.map(&:tag_id)
        assert_equal [tag1.tag_id, tag2.tag_id], artefact.tags.map(&:tag_id)

        # try the case when a request is made without the 'artefact' param
        put :update, :id => artefact.id, :specialist_sectors => [tag1.tag_id]

        artefact.reload
        assert_equal [tag1.tag_id], artefact.specialist_sectors.map(&:tag_id)
        assert_equal [tag1.tag_id], artefact.tags.map(&:tag_id)
      end

      should "Reject JSON requests to update an artefact's owning app" do
        artefact = Artefact.create!(
          slug: "whatever",
          kind: "guide",
          owning_app: "publisher",
          name: "Whatever",
          need_ids: ['100001']
        )
        url_arbiter_has_registration_for("/whatever", "publisher")

        put :update, id: artefact.id, "CONTENT_TYPE" => "application/json", owning_app: 'smart-answers'
        assert_equal 409, response.status
        assert response.body.include? "publisher"
      end

      should "convert nil values for tag attributes to an empty array" do
        artefact = FactoryGirl.create(:artefact)

        stub_current_user = stub("User", has_permission?: true)
        @controller.stubs(:current_user).returns(stub_current_user)

        Artefact.any_instance.expects(:update_attributes_as)
                              .with(stub_current_user, has_entry("specialist_sectors", []))
                              .returns(true)

        put :update, id: artefact.id, format: :json, specialist_sectors: nil
        assert response.ok?
      end

      should "not populate empty arrays for tag types which haven't been provided" do
        artefact = FactoryGirl.create(:artefact)

        stub_current_user = stub("User", has_permission?: true)
        @controller.stubs(:current_user).returns(stub_current_user)

        Artefact.any_instance.expects(:update_attributes_as)
                              .with(stub_current_user, Not(has_key("specialist_sectors")))
                              .returns(true)

        put :update, id: artefact.id, format: :json # not providing 'specialist_sectors' here
        assert response.ok?
      end

      should "split need_ids if they come in as comma-separated values" do
        artefact = FactoryGirl.create(:artefact)

        put :update, id: artefact.id, artefact: { need_ids: "331312,333123" }

        assert_equal ["331312", "333123"], @controller.params[:artefact][:need_ids]
      end

      should "split related_artefact_slugs as they come in as comma-separated values" do
        artefact = FactoryGirl.create(:artefact)

        put :update, id: artefact.id, artefact: { related_artefact_slugs: "benefits-calculators, \nchild-tax-credit" }

        assert_equal ["benefits-calculators", "child-tax-credit"], @controller.params[:artefact][:related_artefact_slugs]
      end

    end

    context "DELETE /artefacts/:id" do
      include GdsApi::TestHelpers::Router

      setup do
        WebMock.stub_request(:delete, "http://search.dev.gov.uk/mainstream/documents/%2Fwhatever").
            to_return(:status => 200)
        WebMock.stub_request(:post, "http://search.dev.gov.uk/mainstream/commit").
            to_return(:status => 200)

        Artefact.observers.disable :all
        @artefact = Artefact.create!(
          slug: "whatever",
          kind: "guide",
          owning_app: "publisher",
          name: "Whatever",
          need_ids: ['100001'],
          paths: ["/whatever"]
        )
        Artefact.observers.enable :all
      end

      context "when a redirect is requested" do
        context "for a relative path" do
          should "mark an artefact as archived" do
            stub_all_router_registration

            delete :destroy, id: @artefact.id, format: :json,
                             artefact: { redirect_url: "/whenever" }
            assert_equal 200, response.status
            @artefact.reload
            assert_equal "archived", @artefact.state
            assert_equal "/whenever", @artefact.redirect_url
          end

          should "add a redirect route" do
            redirect, commit = stub_redirect_registration "/whatever",
                                                          "exact",
                                                          "/whenever",
                                                          "permanent"

            delete :destroy, id: @artefact.id, format: :json,
                             artefact: { redirect_url: "/whenever" }

            assert_requested redirect
            assert_requested commit
          end
        end

        context "for a GOV.UK absolute URL path" do
          should "mark an artefact as archived" do
            stub_all_router_registration

            delete :destroy, id: @artefact.id, format: :json,
                             artefact: { redirect_url: "https://gov.uk/whenever" }
            assert_equal 200, response.status
            @artefact.reload
            assert_equal "archived", @artefact.state
            assert_equal "/whenever", @artefact.redirect_url
          end

          should "add a redirect route" do
            redirect, commit = stub_redirect_registration "/whatever",
                                                          "exact",
                                                          "/whenever",
                                                          "permanent"

            delete :destroy, id: @artefact.id, format: :json,
                             artefact: { redirect_url: "https://gov.uk/whenever" }

            assert_requested redirect
            assert_requested commit
          end
        end
      end

      context "for a non-GOV.UK absolute URL path" do
        should "redirect to the withdraw page with a flash message" do
          delete :destroy, id: @artefact.id, format: :json,
                           artefact: { redirect_url: "https://example.com/whenever" }

          assert_redirected_to withdraw_artefact_path(@artefact.id)
          assert_match /not a valid redirect target/, @controller.flash[:danger]
        end
      end

      context "when a redirect is not requested" do
        should "mark an artefact as archived" do
          stub_all_router_registration

          delete :destroy, id: @artefact.id, format: :json
          assert_equal 200, response.status
          @artefact.reload
          assert_equal "archived", @artefact.state
          assert_nil @artefact.redirect_url
        end

        should "add a Gone route" do
          gone, commit = stub_gone_route_registration "/whatever", "exact"

          delete :destroy, id: @artefact.id, format: :json

          assert_requested gone
          assert_requested commit
        end
      end

      context "for an unknown artefact" do
        should "return a 404" do
          delete :destroy, id: "4567", format: :json
          assert_equal 404, response.status
        end
      end
    end
  end
end
