require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
    TagRepository.put(:tag_id => "crime", :title => "Crime", :tag_type => "section")
    TagRepository.put(:tag_id => "crime/the-police", :title => "The Police", :tag_type => "section")
    @tag_count = 2
  end

  context "GET /tags/:id" do
    should "return tag" do
      get :show, :id => "crime/the-police", :format => "json"
      parsed = JSON.parse(response.body)
      assert_response :success
      assert_equal parsed["status"], "ok"
      assert_equal parsed["tag"]["type"], "section"
      assert_equal parsed["tag"]["id"], "crime/the-police"
      assert_equal parsed["tag"]["title"], "The Police"
    end

    should "return 404" do
      get :show, :id => "crime/the-mafia", :format => "json"
      assert_response :not_found
    end
  end

  context "GET /tags" do
    should "return all the tags" do
      get :index, :format => "json"
      parsed = JSON.parse(response.body)
      assert_response :success
      assert_equal parsed["status"], "ok"
      assert_equal parsed["total"], @tag_count
      assert_equal parsed["results"].count, @tag_count

    end
  end

end
