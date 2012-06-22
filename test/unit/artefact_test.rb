require 'test_helper'

class ArtefactTest < ActiveSupport::TestCase
  setup do
    @artefact = FactoryGirl.create(:artefact)
  end

  test "should set indexable_content on artefacts" do
    @artefact.indexable_content = "Searchy searchy McSearch"
    assert_equal "Searchy searchy McSearch", @artefact.indexable_content
  end

  test "should not persist indexable content" do
    @artefact.indexable_content = "Searchy searchy McSearch"
    @artefact.save

    reloaded_artefact = Artefact.find(@artefact.id)
    assert_nil reloaded_artefact.indexable_content
  end

end
