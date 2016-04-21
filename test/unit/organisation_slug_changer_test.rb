require 'test_helper'
require 'organisation_slug_changer'

class OrganisationSlugChangerTest < ActiveSupport::TestCase
  setup do
    stub_artefact_callbacks

    @organisation = FactoryGirl.create(
      :live_tag,
      tag_type: "organisation",
      tag_id: "organisation-1",
      title: "Organisation One"
    )

    @new_slug = 'new-slug'

    @slug_changer = OrganisationSlugChanger.new(
      @organisation.tag_id,
      @new_slug
    )
  end

  test 'it changes the organisation tag_id' do
    @slug_changer.call

    assert_equal @new_slug, @organisation.reload.tag_id
  end

  test 'updates the organisation_ids of associated artefacts' do
    stub_rummageable_artefact!

    artefact = create_associated_artefact(@organisation)

    @slug_changer.call

    assert_equal [@new_slug], artefact.reload.organisation_ids
  end

  test 'it reindexes the updated artefacts in search' do
    artefact = create_associated_artefact(@organisation)

    rummageable_artefact = stub("rummageable_artefact")
    rummageable_artefact.expects(:submit)
    RummageableArtefact.expects(:new).with(artefact).returns(rummageable_artefact)

    @slug_changer.call
  end

  test 'it does not index an artefact which is owned by whitehall' do
    artefact = create_associated_artefact(@organisation, owning_app: "whitehall")

    RummageableArtefact.expects(:new).with(artefact).never

    @slug_changer.call
  end

  def create_associated_artefact(organisation, extra_attributes = {})
    attributes = {
      organisations: [organisation.tag_id]
    }.merge(extra_attributes)
    FactoryGirl.create(:live_artefact, attributes)
  end

  def stub_rummageable_artefact!
    RummageableArtefact.any_instance.stubs(:submit)
  end
end
