require 'test_helper'

class ParameterExtractorTest < ActiveSupport::TestCase
  test 'a create with params from the UI' do
    params = ActionController::Parameters.new(
      "utf8" => "✓",
      "authenticity_token" => "some-token",
      "artefact" => {
        "kind" => "answer",
        "language" => "en",
        "live" => "1",
        "name" => "This is a test",
        "need_extended_font" => "0",
        "need_ids" => "123123,321321",
        "organisation_ids" => ["", "accelerated-access-review"],
        "owning_app" => "publisher",
        "related_artefact_slugs" => "",
        "sections" => ["visas-immigration/arriving-in-the-uk", "working/armed-forces"],
        "slug" => "my-super-test",
        "specialist_sector_ids" => ["", "animal-welfare/pets"],
      },
      "commit" => "Save and continue editing" )

    result = ParameterExtractor.new(params).extract

    expected = {
      "kind" => "answer",
      "language" => "en",
      "name" => "This is a test",
      "need_extended_font" => "0",
      "need_ids" => ["123123", "321321"],
      "organisation_ids" => ["accelerated-access-review"],
      "owning_app" => "publisher",
      "related_artefact_slugs" => [],
      "sections" => ["visas-immigration/arriving-in-the-uk", "working/armed-forces"],
      "slug" => "my-super-test",
      "specialist_sector_ids" => ["animal-welfare/pets"],
      "state" => "live",
    }
    assert_equal expected, result
  end

  test 'an update with params from the UI' do
    params = ActionController::Parameters.new({
      "utf8" => "✓",
      "authenticity_token" => "some-token",
      "artefact" => {
        "slug" => "my-super-test",
        "related_artefact_slugs" => "",
        "organisation_ids" => ["", "accelerated-access-review"],
        "need_ids" => "121231,123123",
        "language" => "en",
        "need_extended_font" => "0"
      },
      "commit" => "Save and continue editing",
      "id" => "572c9c95759b746c23203cef"
    })

    result = ParameterExtractor.new(params).extract

    expected = {
      "related_artefact_slugs" => [],
      "slug" => "my-super-test",
      "need_ids" => ["121231", "123123"],
      "language" => "en",
      "need_extended_font" => "0",
      "organisation_ids"=>["accelerated-access-review"]
    }
    assert_equal expected, result
  end

  test 'where the params are already arrays' do
    params = ActionController::Parameters.new({
      "artefact" => {
        "need_ids" => ["121231", "123123"],
      },
    })

    result = ParameterExtractor.new(params).extract

    expected = {
      "need_ids" => ["121231", "123123"],
    }
    assert_equal expected, result
  end

  test 'update with params from the API' do
    params = ActionController::Parameters.new({
     "artefact" => {
       "description" =>  "Foo bar.",
       "indexable_content" => "Foo",
       "kind" => "guide",
       "latest_change_note" => nil,
       "name" => "Get a copy of military service records",
       "owning_app" => "publisher",
       "paths" => ["/get-copy-military-service-records.json"],
       "prefixes" => ["/get-copy-military-service-records"],
       "public_timestamp" => "2015-09-24T11:14:16.000+01:00",
       "rendering_app" => "frontend",
       "sections" => ["births-deaths-marriages/register-offices", "working/armed-forces"],
       "slug" => "get-copy-military-service-records",
       "specialist_sectors" => nil,
       "state" => "live",
      }
    })

    result = ParameterExtractor.new(params).extract

    expected = {
      "description" => "Foo bar.",
      "indexable_content" => "Foo",
      "kind" => "guide",
      "latest_change_note" => nil,
      "name" => "Get a copy of military service records",
      "owning_app" => "publisher",
      "paths" => ["/get-copy-military-service-records.json"],
      "prefixes" => ["/get-copy-military-service-records"],
      "public_timestamp" => "2015-09-24T11:14:16.000+01:00",
      "rendering_app" => "frontend",
      "sections" => ["births-deaths-marriages/register-offices", "working/armed-forces"],
      "slug" => "get-copy-military-service-records",
      "specialist_sectors" => [],
      "state" => "live",
    }
    assert_equal expected, result
  end
end
