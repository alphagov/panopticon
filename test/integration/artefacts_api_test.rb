require_relative '../test_helper'

class ArtefactsAPITest < ActiveSupport::TestCase

  setup do
    create_test_user
  end

  context "artefacts index" do
    should "return list of artefacts as JSON" do
      FactoryGirl.create(:artefact, :name => 'Alpha', :slug => 'alpha')
      FactoryGirl.create(:artefact, :name => 'Bravo', :slug => 'bravo')
      FactoryGirl.create(:artefact, :name => 'Charlie', :slug => 'charlie')

      get "/artefacts.json"
      assert_equal 200, last_response.status
      data = JSON.parse(last_response.body)

      slugs = data.map {|item| item["slug"] }
      assert_equal %w(alpha bravo charlie), slugs
    end
  end

  context "show artefact" do
    should "return the JSON representation of the artefact" do
      artefact = FactoryGirl.create(:artefact, :slug => 'wibble', :name => "Wibble", :need_ids => ["100001", "100002"])

      get "/artefacts/wibble.json"

      assert_equal 200, last_response.status
      response = JSON.parse last_response.body

      assert_equal 'wibble', artefact["slug"]
      assert_equal 'Wibble', artefact["name"]
      assert_equal 'answer', artefact["kind"]
      assert_equal 'publisher', artefact["owning_app"]
      assert_equal 'draft', artefact["state"]
      assert_equal ['100001', '100002'], artefact["need_ids"]
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
          'need_extended_font' => false
        }

        # Rack::Test put method calls to_json on whatever body you pass.
        # This is different to the post method.  Go figure.
        put "/artefacts/wibble.json", artefact_data

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
        assert_equal false, artefact.need_extended_font
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

        put "/artefacts/wibble.json", artefact_data

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

        put "/artefacts/foreign-travel-advice/aruba.json", artefact_data

        assert_equal 201, last_response.status

        artefact = Artefact.find_by_slug('foreign-travel-advice/aruba')
        assert artefact
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
            'description' => "Interesting news article",
            'owning_app' => 'whitehall',
            'rendering_app' => 'whitehall-frontend',
          }

          put "/artefacts/#{slug}.json", artefact_data
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

        put "/artefacts/wibble.json", artefact_data

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

      should "return an error if updating the artefact fails" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble 2 - the return',
          'kind' => 'wibble', # invalid kind
          'description' => 'Wibble description',
          'owning_app' => 'publisher',
          'state' => 'draft',
        }

        put "/artefacts/wibble.json", artefact_data

        assert_equal 422, last_response.status
        error_details = JSON.parse(last_response.body)
        assert_equal({"errors" => ["Kind is not included in the list"]}, error_details)

        @artefact.reload
        assert_equal "Wibble", @artefact.name
      end

    end
  end
end
