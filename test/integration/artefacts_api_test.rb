require_relative '../test_helper'

class ArtefactsAPITest < ActiveSupport::TestCase

  setup do
    create_test_user
  end

  context "registering an artefact in panopticon" do
    context "for a new artefact" do
      should "create a new artefact, and return its details" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble',
          'kind' => 'course',
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
        assert_equal 'course', artefact.kind
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

    end # for a new artefact

    context "for an existing artefact" do
      setup do
        @artefact = FactoryGirl.create(:artefact, :slug => 'wibble', :name => "Wibble")
      end

      should "update the artefact" do
        artefact_data = {
          'slug' => 'wibble',
          'name' => 'Wibble 2 - the return',
          'kind' => 'course',
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
        assert_equal 'course', @artefact.kind
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
