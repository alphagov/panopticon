require 'test_helper'
require 'importers/mainstream_organisation_tag_importer'

module Importers
  class MainstreamOrganisationTagImporterTest < ActiveSupport::TestCase
    setup do
      @need_api = stub("GdsApi::NeedApi")
      @importer = MainstreamOrganisationTagImporter.new(@need_api)
    end

    def stub_need_with_organisation_ids(need_id, *organisations)
      organisations.each do |organisation|
        next if Tag.by_tag_id(organisation, type: 'organisation', draft: true)
        create(:live_tag, tag_type: 'organisation', tag_id: organisation)
      end

      stub_need = {
        'organisation_ids' => organisations
      }
      @need_api.expects(:need).with(need_id).returns(stub_need)
    end

    should 'not request a need for an artefact without a need ID' do
      create(:draft_artefact, owning_app: 'publisher', need_ids: nil)

      @need_api.expects(:need).never

      @importer.run
    end

    should 'not request a need for a non-publisher artefact' do
      create(:whitehall_draft_artefact, need_ids: ['100001'])

      @need_api.expects(:need).never

      @importer.run
    end

    should 'not request a need for an archived artefact' do
      # disable observers whilst we create the artefact, so that we don't try to
      # register with the router or index in search
      Artefact.observers.disable :all do
        create(:archived_artefact, owning_app: 'publisher', need_ids: ['100001'])
      end

      @need_api.expects(:need).never

      @importer.run
    end

    should 'not request a need that is not a Maslow need ID' do
      # as new need_ids are now validated to the Maslow format, we have to set the
      # need_ids field manually so that we avoid validation.
      artefact = create(:draft_artefact, owning_app: 'publisher')
      artefact.update_attribute(:need_ids, %w(123 B123))

      @need_api.expects(:need).never

      @importer.run
    end

    should 'assign organisations for a need to a publisher artefact with a need ID' do
      artefact = create(:draft_artefact, owning_app: 'publisher', need_ids: ['100001'])
      stub_need_with_organisation_ids('100001', 'department-for-work-pensions',
                                                'ministry-of-justice')

      @importer.run
      artefact.reload

      assert_equal ['department-for-work-pensions', 'ministry-of-justice'],
                   artefact.organisation_ids
    end

    should 'assign organisations for all needs to a publisher artefact with multiple need IDs' do
      artefact = create(:draft_artefact, owning_app: 'publisher', need_ids: %w(100001 100002))
      stub_need_with_organisation_ids('100001', 'home-office',
                                                'uk-visas-and-immigration')
      stub_need_with_organisation_ids('100002', 'environment-agency')

      @importer.run
      artefact.reload

      assert_equal ['home-office', 'uk-visas-and-immigration', 'environment-agency'],
                   artefact.organisation_ids
    end

    should 'not remove existing organisation tags from the artefact' do
      create(:live_tag, tag_type: 'organisation', tag_id: 'ministry-of-defence')
      artefact = create(:draft_artefact, owning_app: 'publisher',
                                         need_ids: ['100001'],
                                         organisation_ids: ['ministry-of-defence'])

      stub_need_with_organisation_ids('100001', 'home-office')

      @importer.run
      artefact.reload

      assert_equal ['ministry-of-defence', 'home-office'], artefact.organisation_ids
    end

    should 'not tag the same new organisation multiple times to an artefact' do
      artefact = create(:draft_artefact, owning_app: 'publisher', need_ids: %w(100001 100002))
      stub_need_with_organisation_ids('100001', 'home-office',
                                                'uk-visas-and-immigration')
      stub_need_with_organisation_ids('100002', 'home-office')

      @importer.run
      artefact.reload

      assert_equal ['home-office', 'uk-visas-and-immigration'],
                   artefact.organisation_ids
    end

    should 'not tag an organisation to an artefact to which it is already tagged' do
      create(:live_tag, tag_type: 'organisation', tag_id: 'ministry-of-defence')
      artefact = create(:draft_artefact, owning_app: 'publisher',
                                         need_ids: ['100001'],
                                         organisation_ids: ['ministry-of-defence'])

      stub_need_with_organisation_ids('100001', 'ministry-of-defence')

      @importer.run
      artefact.reload

      assert_equal ['ministry-of-defence'], artefact.organisation_ids
    end

    should 'assign organisations for any present needs to an artefact with incorrect need IDs' do
      artefact = create(:draft_artefact, owning_app: 'publisher',
                                         need_ids: %w(100001 100002 100003))

      stub_need_with_organisation_ids('100001', 'home-office')
      stub_need_with_organisation_ids('100002', 'environment-agency')

      # stub a nil response from the api adapter as if this need does not exist
      @need_api.expects(:need).with('100003').returns(nil)

      @importer.run
      artefact.reload

      assert_equal ['home-office', 'environment-agency'], artefact.organisation_ids
    end

    should 'retry if fetching a need times out' do
      artefact = create(:draft_artefact, owning_app: 'publisher', need_ids: ['100001'])
      create(:live_tag, tag_type: 'organisation', tag_id: "hm-treasury")

      stub_need = {
        "organisation_ids" => ["hm-treasury"]
      }
      @need_api.stubs(:need).with(artefact.need_ids.first)
        .raises(GdsApi::TimedOutException)
        .then.returns(stub_need)

      @importer.run

      artefact.reload
      assert_equal ['hm-treasury'], artefact.organisation_ids
    end
  end
end
