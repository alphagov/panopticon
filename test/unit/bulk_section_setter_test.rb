require 'test_helper'
require 'bulk_section_setter'

class BulkSectionSetterTest < ActiveSupport::TestCase
  def sample_bulk_section_settings_file
    File.expand_path("../fixtures/sample_bulk_section_settings.txt", File.dirname(__FILE__))
  end

  test "Reads settings from a file" do
    setter = BulkSectionSetter.new(sample_bulk_section_settings_file)
    assert_equal 1, setter.artefacts.size
    expected_artefact = {title: "Article Title", section: "Section", subsection: "SubSection"}
    assert_equal expected_artefact, setter.artefacts.first
  end

  test "Apply section to artefacts which can be found" do
    artefact = stub_everything("Article")
    Artefact.expects(:find_by_name).with('Article Title').returns(artefact)
    s = sequence("setting section")
    artefact.expects(:section=).with("Section:SubSection").in_sequence(s)
    artefact.expects(:save!).in_sequence(s)

    setter = BulkSectionSetter.new(sample_bulk_section_settings_file)
    setter.set_all
  end

  test "Keep a log of artefacts which could not be found" do
    logger = stub("Logger")
    Artefact.stubs(:find_by_name).returns(nil)
    logger.expects(:warn).with("Couldn't find 'Article Title' to set section 'Section:SubSection'")

    setter = BulkSectionSetter.new(sample_bulk_section_settings_file, logger)
    setter.set_all
  end

  test "Catch validation errors on save" do
    artefact = stub("Article")
    artefact.stubs(:section=)
    artefact.stubs(:save!).raises("something bad happened")
    Artefact.expects(:find_by_name).returns(artefact)
    logger = stub("Logger")
    logger.expects(:warn).with(regexp_matches(/Couldn't save 'Article Title' because /))
    setter = BulkSectionSetter.new(sample_bulk_section_settings_file, logger)
    setter.set_all
  end
end
