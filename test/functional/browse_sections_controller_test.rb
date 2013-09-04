require 'test_helper'

class BrowseSectionsControllerTest < ActionController::TestCase

  def login_as_user_with_permission
    u = stub_user
    u.permissions = u.permissions + ["Browse section admin"]
    u.save!
    login_as(u)
  end

  def stub_search_delete
    WebMock.stub_request(:any, %r{\A#{SEARCH_ROOT}}).to_return(status: 200)
  end

  setup do
    stub_search_delete # search deletes happen when creating an archived edition
  end

  context "access control" do
    should "only grant access to users with permission" do
      login_as_stub_user
      get :index
      assert_response 403
    end
  end

  context "GET index" do
    setup do
      login_as_user_with_permission
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
      FactoryGirl.create(:tag, tag_type: "section", tag_id: "a/1", title: "1", parent_id: "a")
    end

    should "list browse sections" do
      get :index
      assert_select "tbody tr", 2
    end
  end

  context "GET edit" do
    setup do
      login_as_user_with_permission
    end

    context "top level section" do
      setup do
        @section = FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
      end

      should "not show the curated UI" do
        get :edit, id: @section.id
        # TODO very fragile test, will easily break silently
        assert_select "curated-artefact-group", 0
      end
    end

    context "is a subsection" do
      setup do
        @parent = FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
        @section = FactoryGirl.create(:tag, tag_type: "section", tag_id: "a/1", title: "1", parent_id: @parent.id)
      end

      context "has a curated list" do
        setup do
          @artefact = FactoryGirl.create(:artefact, name: "Relic", sections: [@section].map(&:tag_id))
          tag_id_as_curated_list_slug = @section.tag_id.gsub(%r{/}, "-")
          @curated_list = FactoryGirl.create(:curated_list, slug: tag_id_as_curated_list_slug, artefact_ids: [@artefact.id])
        end

        should "show the artefacts" do
          get :edit, id: @section.id
          assert_select "option[value=#{@artefact.id}][selected=selected]", "Relic"
        end

        context "some items in the curated list are archived" do
          setup do
            @arch_artefact = FactoryGirl.create(:artefact, state: "archived", name: "Unwanted", sections: [@section].map(&:tag_id))
            @curated_list.artefact_ids = @curated_list.artefact_ids + [@arch_artefact.id]
            @curated_list.save!
          end

          should "render the non-archived items" do
            get :edit, id: @section.id
            assert_select ".curated-artefact select", count: 1
          end
        end
      end

      context "some artefacts in the section are archived" do
        setup do
          @live_artefact = FactoryGirl.create(:artefact, name: "Relic", sections: [@section].map(&:tag_id))
          @arch_artefact = FactoryGirl.create(:artefact, state: "archived", name: "Unwanted", sections: [@section].map(&:tag_id))
        end

        should "not include them in the dropdown list" do
          get :edit, id: @section.id
          assert_select "option[value=#{@live_artefact.id}]", text: "Relic"
          assert_select "option[value=#{@arch_artefact.id}]", text: "Unwanted", count: 0
        end
      end

      context "doesn't have a curated list (yet)" do
        should "still work" do
          get :edit, id: @section.id
          assert_response 200
        end
      end
    end
  end

  context "PUT update" do
    setup do
      login_as_user_with_permission
      @section = FactoryGirl.create(:tag, tag_type: "section", tag_id: "a", title: "A")
    end

    should "update the section tag" do
      put :update, id: @section.id, section: { title: "Amore" }
      assert_equal "Amore", @section.reload.title
      assert_redirected_to browse_sections_path
      assert_match(/updated/i, flash[:notice])
    end

    should "rerender the form if invalid" do
      put :update, id: @section.id, section: { title: "" }
      assert_template :edit
      assert_match(/Failed to save/i, flash[:error])
    end

    should "prevent updates to the tag_id (slug)" do
      put :update, id: @section.id, section: { tag_id: "h4x0r" }
      assert_equal "a", @section.reload.tag_id
    end

    context "changing the curated list" do
      setup do
        @parent_section = @section
        @section = FactoryGirl.create(:tag, tag_type: "section", tag_id: "a/1", title: "1", parent_id: "a")
        @artefact = FactoryGirl.create(:artefact, name: "Relic", sections: [@section].map(&:tag_id))
      end

      should "strip blank artefact_ids" do
        put :update, id: @section.id, section: {}, curated_list: { artefact_ids: [@artefact.id, ""] }
        curated_list = CuratedList.where(slug: @section.tag_id.gsub(%r{/}, "-")).first
        refute_nil curated_list
        assert_equal [@artefact.id], curated_list.artefact_ids
      end

      context "a curated_list already exists" do
        setup do
          tag_id_as_curated_list_slug = @section.tag_id.gsub(%r{/}, "-")
          @curated_list = FactoryGirl.create(:curated_list, slug: tag_id_as_curated_list_slug, artefact_ids: [@artefact.id])
        end

        should "update it" do
          put :update, id: @section.id, section: {}, curated_list: { artefact_ids: [] }
          curated_list = CuratedList.where(slug: @section.tag_id.gsub(%r{/}, "-")).first
          refute_nil curated_list
          assert_equal [], curated_list.artefact_ids
        end
      end

      context "a curated_list doesn't already exist" do
        should "create one and populate it" do
          put :update, id: @section.id, section: {}, curated_list: { artefact_ids: [@artefact.id] }
          curated_list = CuratedList.where(slug: @section.tag_id.gsub(%r{/}, "-")).first
          refute_nil curated_list
          assert_equal [@artefact.id], curated_list.artefact_ids
          assert_equal [@section.tag_id], curated_list.tag_ids
        end
      end
    end
  end
end
