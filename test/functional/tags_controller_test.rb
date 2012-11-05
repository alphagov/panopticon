require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
    TagRepository.put(tag_id: "crime", title: "Crime", tag_type: "section",
                      short_description: "Legal processes, courts and the police")
    TagRepository.put(tag_id: "crime/the-police", title: "The Police", tag_type: "section")
    @tag_count = 2
  end

  context "GET /tags/:id" do
    should "return tag" do
      get :show, id: "crime", format: "json"
      parsed = JSON.parse(response.body)
      assert_response :success
      assert_equal parsed["status"], "ok"
      assert_equal parsed["tag"]["type"], "section"
      assert_equal parsed["tag"]["id"], "crime"
      assert_equal parsed["tag"]["title"], "Crime"
      assert_match /Legal processes, courts and the police/, parsed["tag"]["short_description"]
    end

    should "return 404" do
      get :show, id: "crime/the-mafia", format: "json"
      assert_response :not_found
    end
  end

  context "GET /tags" do
    should "return all the tags" do
      get :index, format: "json"
      parsed = JSON.parse(response.body)
      assert_response :success
      assert_equal parsed["status"], "ok"
      assert_equal parsed["total"], @tag_count
      assert_equal parsed["results"].count, @tag_count
    end
  end

  context "GET /tags?type=X" do
    should "return only tags of a particular type" do
      TagRepository.put(tag_id: "minister-of-silly", title: "Minister of Silly", tag_type: "role")
      get :index, format: "json", type: "section"
      parsed = JSON.parse(response.body)
      assert_equal 2, parsed["results"].count
      refute parsed["results"].any? { |result| result["id"] == "minister-of-silly" }
    end
  end
end
