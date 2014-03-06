require 'test_helper'
require 'gds_api/test_helpers/organisations'

require 'organisation_importer'

class OrganisationImporterTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Organisations

  should "create and update multiple organisations" do
    organisations_api_has_organisations(["cabinet-office", "home-office", "ordnance-survey"])

    importer = OrganisationImporter.new

    importer.expects(:create_or_update_organisation).with(responds_with(:title, "Cabinet Office"))
    importer.expects(:create_or_update_organisation).with(responds_with(:title, "Home Office"))
    importer.expects(:create_or_update_organisation).with(responds_with(:title, "Ordnance Survey"))

    importer.run
  end

  should "create a tag for a new organisation" do
    organisations_api_has_organisations(["cabinet-office"])

    assert_difference ->{ Tag.where(tag_type: "organisation").count } do
      OrganisationImporter.new.run
    end

    created_tag = Tag.by_tag_id("cabinet-office", "organisation")
    assert_equal "Cabinet Office", created_tag.title
  end

  should "not create a tag for an existing organisation" do
    Tag.create!(tag_type: "organisation", tag_id: "cabinet-office", title: "Cabinet Office")

    organisations_api_has_organisations(["cabinet-office"])
    assert_difference ->{ Tag.where(tag_type: "organisation").count }, 0 do
      OrganisationImporter.new.run
    end
  end

  should "update the title of an existing organisation if it has changed" do
    Tag.create!(tag_type: "organisation",
                tag_id: "cabinet-office",
                title: "An organisation by any other name")

    organisations_api_has_organisations(["cabinet-office"])
    OrganisationImporter.new.run

    organisation_tag = Tag.by_tag_id("cabinet-office", "organisation")
    assert_equal "Cabinet Office", organisation_tag.title
  end

  should "not update the title of an existing organisation if it hasn't changed" do
    Tag.create!(tag_type: "organisation", tag_id: "cabinet-office", title: "Cabinet Office")

    # assert that no tags are updated during the import run
    Tag.any_instance.expects(:update_attributes).never

    organisations_api_has_organisations(["cabinet-office"])
    OrganisationImporter.new.run
  end

  should "notify Airbrake if creating an organisation fails" do
    organisations_api_has_organisations(["cabinet-office"])

    Tag.any_instance.expects(:save).returns(false)

    Airbrake.expects(:notify_or_ignore).with {|exception, options|
      options.has_key?(:parameters) &&
        options[:parameters].has_key?(:organisation) &&
        options[:parameters][:organisation].title == "Cabinet Office"
    }

    OrganisationImporter.new.run
  end

  should "notify Airbrake if updating an organisation fails" do
    Tag.create!(tag_type: "organisation", tag_id: "cabinet-office", title: "Something else")
    organisations_api_has_organisations(["cabinet-office"])

    Tag.any_instance.expects(:update_attributes).returns(false)

    Airbrake.expects(:notify_or_ignore).with {|exception, options|
      options.has_key?(:parameters) &&
        options[:parameters].has_key?(:organisation) &&
        options[:parameters][:organisation].title == "Cabinet Office"
    }

    OrganisationImporter.new.run
  end

end
