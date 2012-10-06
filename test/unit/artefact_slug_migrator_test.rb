require 'test_helper'
require 'artefact_slug_migrator'

class ArtefactSlugMigratorTest < ActiveSupport::TestCase

  setup do
    @artefacts = [
      FactoryGirl.create(:artefact, :slug => "first-original-slug"),
      FactoryGirl.create(:artefact, :slug => "second-original-slug"),
      FactoryGirl.create(:artefact, :slug => "third-original-slug")
    ]

    ArtefactSlugMigrator.any_instance.stubs(:slugs).returns({
        "first-original-slug" => "first-new-slug",
        "second-original-slug" => "second-new-slug",
        "third-original-slug" => "third-new-slug"
      })
  end

  should "remove artefact from search" do
    RummageableArtefact.any_instance.expects(:delete).at_least_once.returns(true)

    ArtefactSlugMigrator.new.run
  end

  should "update the slug in the artefact" do
    RummageableArtefact.any_instance.stubs(:delete).returns(true)

    ArtefactSlugMigrator.new.run

    @artefacts.each(&:reload)
    assert_equal ["first-new-slug", "second-new-slug", "third-new-slug"], @artefacts.map(&:slug)
  end

end
