require "test_helper"

class CuratedListsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  test "return a json representation of the lists" do
    jury = Artefact.create(name: "Jury Service", slug: "jury-service",
      kind: "guide", owning_app: "publisher")
    crime = CuratedList.create(slug: "crime-and-justice")
    crime.artefact_ids << jury.id
    crime.save

    expected = {
      "crime-and-justice" => ["jury-service"]
    }
    get :index, format: :json
    assert_equal 200, response.status
    assert_equal expected, JSON.parse(response.body)
  end

  test "should retain the order of the IDs in artefact_ids" do
    jury = Artefact.create(name: "Jury Service", slug: "jury-service",
      kind: "guide", owning_app: "publisher")
    to_court = Artefact.create(name: "Court", slug: "going-to-court-victim-witness", kind: "guide", owning_app: "publisher")
    crime = CuratedList.create(slug: "crime-and-justice")
    crime.artefact_ids << jury.id
    crime.artefact_ids << to_court.id
    crime.save

    expected = {
      "crime-and-justice" => [
        "jury-service",
        "going-to-court-victim-witness"
      ]
    }
    get :index, format: :json
    assert_equal 200, response.status
    assert_equal expected, JSON.parse(response.body)
  end
end
