require_relative '../test_helper'

class ArtefactsAPITest < ActiveSupport::TestCase

  setup do
    create_test_user
    header "Content-Type", "application/json"
    stub_request(:patch, %r[http://publishing-api.dev.gov.uk/v2/links/*]).to_return(body: {}.to_json)
  end

  context "artefacts index" do
    should "return list of artefacts as JSON" do
      FactoryGirl.create(:artefact, :name => 'Alpha', :slug => 'alpha', :content_id => '2bd6f4e4-9e47-4952-b1ac-b3799f9368ff')
      FactoryGirl.create(:artefact, :name => 'Bravo', :slug => 'bravo')
      FactoryGirl.create(:artefact, :name => 'Charlie', :slug => 'charlie')

      get "/artefacts.json"
      assert_equal 200, last_response.status
      data = JSON.parse(last_response.body)

      slugs = data.map {|item| item["slug"] }
      assert_equal %w(alpha bravo charlie), slugs

      # Including the actions in the index is expensive, and unnecessary
      refute data.first.has_key?("actions")
    end
  end

  context "show artefact" do
    should "return the JSON representation of the artefact" do
      artefact = FactoryGirl.create(:artefact,
        :slug => 'wibble',
        :name => 'Wibble',
        :need_ids => ['100001', '100002'],
        :content_id => '436b83ff-dc72-4278-a336-199344be4a33',
      )

      get "/artefacts/wibble.json"

      assert_equal 200, last_response.status
      response = JSON.parse last_response.body

      assert_equal 'wibble', artefact["slug"]
      assert_equal 'Wibble', artefact["name"]
      assert_equal 'answer', artefact["kind"]
      assert_equal 'publisher', artefact["owning_app"]
      assert_equal 'draft', artefact["state"]
      assert_equal ['100001', '100002'], artefact["need_ids"]
      assert_equal '436b83ff-dc72-4278-a336-199344be4a33', artefact.content_id
    end
  end

  context "registering an artefact in panopticon" do
    context "for a new artefact" do
      should "create a new artefact" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble',
          'kind' => 'answer',
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'rendering_app' => 'frontend',
          'state' => 'draft',
          'content_id' => 'f392ddac-f600-4963-a3f4-9a82985582f7',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 201, last_response.status

        artefact = Artefact.find_by_slug('wibble')
        assert artefact
        assert_equal 'wibble', artefact.slug
        assert_equal 'Wibble', artefact.name
        assert_equal 'answer', artefact.kind
        assert_equal 'Wibble description', artefact.description
        assert_equal 'publisher', artefact.owning_app
        assert_equal 'frontend', artefact.rendering_app
        assert_equal 'draft', artefact.state
        assert_equal 'f392ddac-f600-4963-a3f4-9a82985582f7', artefact.content_id
      end

      should "return an error if creating an artefact fails" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble',
          'kind' => 'wibble', # invalid kind
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 422, last_response.status
        error_details = JSON.parse(last_response.body)
        assert_equal({"errors" => ["Kind is not included in the list"]}, error_details)
      end

      should "support travel-advice artefacts with a foreign-travel-advice/foo style slug" do
        artefact_data = {
          'slug' => 'foreign-travel-advice/aruba',
          'name' => 'Aruba travel advice',
          'kind' => 'travel-advice',
          'description' => 'Travel advice for people travelling to Aruba',
          'owning_app' => 'travel-advice-publisher',
          'rendering_app' => 'frontend',
          'state' => 'draft',
        }

        put "/artefacts/foreign-travel-advice/aruba.json", artefact_data.to_json

        assert_equal 201, last_response.status

        artefact = Artefact.find_by_slug('foreign-travel-advice/aruba')
        assert artefact
      end

      should "return an error if publishing-api rejects the registration" do
        publishing_api_has_path_reservation_for("/wibble", "a-different-backend")

        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble',
          'kind' => 'answer',
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'rendering_app' => 'frontend',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 409, last_response.status
        assert_equal "Path is already reserved by the a-different-backend application", last_response.body.strip

        assert_nil Artefact.find_by_slug('wibble')
      end

      should "not blow up if not given an owning-app" do
        # simulate the error that publishing-api would return if it was called
        publishing_api_returns_path_reservation_validation_error_for("/wibble", "publishing_app" => ["can't be blank"])

        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble',
          'kind' => 'answer',
          'description' => 'Wibble description',
          'owning_app' => '',
          'rendering_app' => 'frontend',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 422, last_response.status
        error_details = JSON.parse(last_response.body)
        assert_equal({"errors" => ["Owning app can't be blank"]}, error_details)

        assert_nil Artefact.find_by_slug('wibble')
      end

      [
        'fr',
        'zh-hk',
        'es-419',
      ].each do |locale|
        should "support whitehall artefact slugs ending with a locale '.#{locale}'" do
          slug = "government/world-location-news/221033.#{locale}"
          artefact_data = {
            'slug' => slug,
            'name' => "News article in locale #{locale}",
            'kind' => 'world_location_news_article',
            'description' => 'Interesting news article',
            'owning_app' => 'whitehall',
            'rendering_app' => 'whitehall-frontend',
          }

          put "/artefacts/#{slug}.json", artefact_data.to_json
          assert_equal 201, last_response.status

          artefact = Artefact.find_by_slug(slug)
          assert artefact
        end
      end
    end # for a new artefact

    context "for an existing artefact" do
      setup do
        @artefact = FactoryGirl.create(:artefact, :slug => 'wibble', :name => "Wibble")
      end

      should "update the artefact" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble 2 - the return',
          'kind' => 'answer',
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'rendering_app' => 'frontend',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 200, last_response.status

        @artefact.reload
        assert_equal 'wibble', @artefact.slug
        assert_equal 'Wibble 2 - the return', @artefact.name
        assert_equal 'answer', @artefact.kind
        assert_equal 'Wibble description', @artefact.description
        assert_equal 'publisher', @artefact.owning_app
        assert_equal 'frontend', @artefact.rendering_app
        assert_equal 'draft', @artefact.state
      end

      should "update the artefact with mainstream browse pages" do

        FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "business", parent_id: nil, title: "Business")
        FactoryGirl.create(:live_tag, tag_type: "section", tag_id: "business/employing-people", parent_id: "business", title: "Employing people")

        artefact_data = {
            'slug' => 'wibble',
            'name' => 'Wibble 2 - the return',
            'kind' => 'answer',
            'description' => 'Wibble description',
            'owning_app' => 'publisher',
            'rendering_app' => 'frontend',
            'state' => 'draft',
            'sections' => ['business/employing-people'],
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 200, last_response.status

        @artefact.reload
        assert_equal ['business/employing-people'], @artefact.tags.map(&:tag_id)
      end

      should "add content_id to an artefact that does not have one" do
        artefact_data = { 'content_id' => '105e2299-dcfe-4301-b8e0-56959ce95ec0' }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 200, last_response.status

        @artefact.reload

        assert_equal '105e2299-dcfe-4301-b8e0-56959ce95ec0', @artefact.content_id
      end

      should "return an error if updating the artefact fails" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble 2 - the return',
          'kind' => 'wibble', # invalid kind
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 422, last_response.status
        error_details = JSON.parse(last_response.body)
        assert_equal({"errors" => ["Kind is not included in the list"]}, error_details)

        @artefact.reload
        assert_equal "Wibble", @artefact.name
      end

      should "return an error if publishing-api rejects the registration" do
        publishing_api_has_path_reservation_for("/wibble", "a-different-backend")

        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble 2 - the return',
          'kind' => 'answer',
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'rendering_app' => 'frontend',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 409, last_response.status
        assert_equal "Path is already reserved by the a-different-backend application", last_response.body.strip

        @artefact.reload
        assert_equal "Wibble", @artefact.name
      end

      should "not blow up if not given an owning-app" do
        # simulate the error that publishing-api would return if it was called
        publishing_api_returns_path_reservation_validation_error_for("/wibble", "publishing_app" => ["can't be blank"])

        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble 2 - the return',
          'kind' => 'answer',
          'description' => 'Wibble description',
          'owning_app' => '',
          'rendering_app' => 'frontend',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data.to_json

        assert_equal 422, last_response.status
        error_details = JSON.parse(last_response.body)
        assert_equal({"errors" => ["Owning app can't be blank"]}, error_details)

        @artefact.reload
        assert_equal "Wibble", @artefact.name
      end
    end
  end
end
