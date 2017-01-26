require 'test_helper'
require 'gds_api/test_helpers/publishing_api'
require 'gds_api/test_helpers/router'

class ArtefactsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
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
        FactoryGirl.create_list(:artefact, 10, owning_app: 'publisher')
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
          @scope.expects(:of_kind).with("answer").returns(@scope)
          @scope.expects(:in_state).with("live").returns(@scope)
          @scope.expects(:matching_query).with("foo").returns(@scope)

          get :index, kind: "answer", state: "live", search: "foo"
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
        should "be invalid with a malformed need_id" do
          artefact1 = FactoryGirl.create(:artefact)
          artefact1.name = ""
          put :update, id: artefact1.id, artefact: { need_ids: "XXX" }
          assert_template :edit
        end
      end

      should "redirect to GET edit" do
        artefact = FactoryGirl.create(:artefact, owning_app: "smartanswers", kind: "smart-answer")
        put :update, :id => artefact.id, :artefact => { :owning_app => 'smartanswers', :slug => 'whatever', :kind => 'smart-answer', :name => 'Whatever', :need_ids => '100001' }

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
end
