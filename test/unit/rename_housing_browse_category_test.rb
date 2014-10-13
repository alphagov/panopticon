require 'test_helper'
require_relative '../../db/migrate/20140926081837_rename_housing_browse_category'

class RenameHousingBrowseCategoryTest < ActiveSupport::TestCase
  setup do
    stub_all_router_api_requests
    stub_all_rummager_requests
  end

  test "self.up renames 'housing' categories" do
    FactoryGirl.create(:tag, tag_id: "housing", title: "Housing", tag_type: 'section', state: "live")
    FactoryGirl.create(:tag, tag_id: "housing/landlords", title: "Housing and landlords", tag_type: 'section', parent_id: "housing", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing/owning-renting-property", title: "Owning and renting property", tag_type: 'section', parent_id: "housing", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing/council-housing-association", title: "Council housing and housing association", tag_type: 'section', parent_id: "housing", state: "live")
    FactoryGirl.create(:tag, tag_id: "something", title: "Something", tag_type: "section", state: "live")
    FactoryGirl.create(:tag, tag_id: "dwp", title: "DWP", tag_type: 'organisation', state: "live")
    artefact1 = FactoryGirl.create(:artefact, slug: "park-mobile-homes", state: "live")
    artefact1.sections = ["housing/landlords", "housing/owning-renting-property", "housing/council-housing-association", "something"]
    artefact1.organisations = ["dwp"]
    artefact1.save!

    artefact2 = FactoryGirl.create(:artefact, slug: "scaffolding-rules", state: "live")
    artefact2.section_ids = ["housing/landlords", "something"]
    artefact2.save!

    artefact3 = FactoryGirl.create(:artefact, slug: "expensive-rents", state: "archived")
    artefact3.section_ids = ["housing/landlords", "something"]
    artefact3.save!


    RenameHousingBrowseCategory.up

    assert Tag.where(tag_id: "housing-local-services").exists?
    assert Tag.where(tag_id: "housing-local-services/owning-renting-property").exists?
    assert Tag.where(tag_id: "housing-local-services/council-housing-association").exists?
    assert Tag.where(tag_id: "housing-local-services/landlords", parent_id: "housing-local-services").exists?
    assert Tag.where(tag_id: "something").exists?
    assert Tag.where(tag_id: "dwp").exists?

    retagged_artefacts = Artefact.any_in(tag_ids: [/housing-local-services/]).all

    assert_equal 2, retagged_artefacts.size

    assert retagged_artefacts.first.section_ids.include?("housing-local-services/landlords")
    assert retagged_artefacts.first.section_ids.include?("housing-local-services/owning-renting-property")
    assert retagged_artefacts.first.section_ids.include?("housing-local-services/council-housing-association")
    assert retagged_artefacts.first.organisation_ids.include?("dwp")
    assert retagged_artefacts.last.section_ids.include?("housing-local-services/landlords")
    refute retagged_artefacts.last.section_ids.include?("housing-local-services/owning-renting-property")

    assert_equal 3, Artefact.any_in(tag_ids: [/something/]).count
  end

  test "self.down undoes renaming" do
    FactoryGirl.create(:tag, tag_id: "housing", title: "Housing", tag_type: 'section', state: "live")
    FactoryGirl.create(:tag, tag_id: "housing/landlords", title: "Housing and landlords", tag_type: 'section', parent_id: "housing", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing/owning-renting-property", title: "Owning and renting property", tag_type: 'section', parent_id: "housing", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing/council-housing-association", title: "Council housing and housing association", tag_type: 'section', parent_id: "housing", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing-local-services", title: "Housing", tag_type: 'section', state: "live")
    FactoryGirl.create(:tag, tag_id: "housing-local-services/landlords", title: "Housing and landlords", tag_type: 'section', parent_id: "housing-local-services", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing-local-services/owning-renting-property", title: "Owning and renting property", tag_type: 'section', parent_id: "housing-local-services", state: "live")
    FactoryGirl.create(:tag, tag_id: "housing-local-services/council-housing-association", title: "Council housing and housing association", tag_type: 'section', parent_id: "housing-local-services", state: "live")
    FactoryGirl.create(:tag, tag_id: "something", title: "Something", tag_type: 'section', state: "live")
    artefact1 = FactoryGirl.create(:artefact, slug: "park-mobile-homes", state: "live")
    artefact1.section_ids = ["housing-local-services/landlords", "housing-local-services/owning-renting-property", "something"]
    artefact1.save!

    artefact2 = FactoryGirl.create(:artefact, slug: "expensive-rents", state: "archived")
    artefact2.section_ids = ["housing-local-services/landlords", "something"]
    artefact2.save!

    artefact3 = FactoryGirl.create(:artefact, slug: "scaffolding-rules", state: "live")
    artefact3.section_ids = ["housing-local-services/landlords", "something"]
    artefact3.save!


    RenameHousingBrowseCategory.down

    assert Tag.where(tag_id: "housing").exists?
    assert Tag.where(tag_id: "housing/landlords", parent_id: "housing").exists?
    assert Tag.where(tag_id: "something").exists?

    retagged_artefacts = Artefact.any_in(tag_ids: [/housing/]).all

    puts retagged_artefacts.first.inspect
    assert_equal 3, retagged_artefacts.size
    assert retagged_artefacts.first.tag_ids.include?("housing/landlords")
    assert retagged_artefacts.first.tag_ids.include?("housing/owning-renting-property")
    assert retagged_artefacts.last.tag_ids.include?("housing/landlords")
    refute retagged_artefacts.last.tag_ids.include?("housing/owning-renting-property")

    assert_equal 3, Artefact.any_in(tag_ids: [/something/]).count

  end

end
