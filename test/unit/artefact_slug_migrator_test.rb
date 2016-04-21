require 'test_helper'
require 'artefact_slug_migrator'

class ArtefactSlugMigratorTest < ActiveSupport::TestCase

  setup do
    # stub the observers for creating artefacts
    Artefact.any_instance.stubs(:update_router)
    Artefact.any_instance.stubs(:update_search)

    @artefacts = [
      FactoryGirl.create(:artefact, :slug => "first-original-slug"),
      FactoryGirl.create(:artefact, :slug => "second-original-slug", :state => 'live'),
      FactoryGirl.create(:artefact, :slug => "third-original-slug", :state => 'archived')
    ]

    @it = ArtefactSlugMigrator.new( Logger.new("/dev/null") )

    RummageableArtefact.any_instance.stubs(:delete).returns(true)
    ArtefactSlugMigrator.any_instance.stubs(:slugs).returns({
        "first-original-slug" => "first-new-slug",
        "second-original-slug" => "second-new-slug",
        "third-original-slug" => "third-new-slug"
      })
    # Remove the update_search callback stub, as it should short-circuit.
    Artefact.any_instance.unstub(:update_search)
  end

  should "remove artefact from search" do
    RummageableArtefact.any_instance.expects(:delete).at_least_once.returns(true)

    @it.run
  end

  should "update the slug in the artefact" do
    @it.run

    @artefacts.each(&:reload)
    assert_equal ["first-new-slug", "second-new-slug", "third-new-slug"], @artefacts.map(&:slug)
  end

end
