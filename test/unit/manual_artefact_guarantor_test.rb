require 'test_helper'
require 'gds_api/test_helpers/content_store'
require 'manual_artefact_guarantor'

class ManualArtefactGuarantorTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  def generate_content_id
    SecureRandom.uuid
  end

  def manual_item(slug)
    content_item_for_base_path("/guidance/#{slug}").merge({ 'format' => 'manual', 'content_id' => generate_content_id })
  end

  setup do
    RoutableArtefact.any_instance.stubs(:submit)
  end

  should "return an unsuccessful result if the slug does not exist in the content store" do
    content_store_does_not_have_item('/guidance/missing-item')

    mag = ManualArtefactGuarantor.new('missing-item')
    response = mag.guarantee
    assert_equal false, response.success?
    assert_match /does not exist/, response.message
  end

  should "fetch the content_item for the specified manual slug from the content store" do
    manual_item = manual_item('a-manual')
    content_store_has_item('/guidance/a-manual', manual_item)

    mag = ManualArtefactGuarantor.new('a-manual')

    assert_equal manual_item['content_id'], mag.content_item.content_id
  end

  should "return an unsuccessful result if the content_item is not a manual" do
    not_a_manual = content_item_for_base_path('/guidance/not-a-manual').merge({ 'format' => 'license', 'content_id' => generate_content_id })
    content_store_has_item('/guidance/not-a-manual', not_a_manual)

    mag = ManualArtefactGuarantor.new('not-a-manual')
    response = mag.guarantee
    assert_equal false, response.success?
    assert_match /is not a manual/, response.message
  end

  context 'when there is already an artefact for the slug' do
    setup do
      @manual_item = manual_item('a-manual-with-artefact')
      content_store_has_item('/guidance/a-manual-with-artefact', @manual_item)
      @artefact = FactoryGirl.create(:artefact,
        slug: 'guidance/a-manual-with-artefact',
        owning_app: 'specialist-publisher',
        kind: 'manual',
        content_id: @manual_item['content_id']
      )
    end

    should "return a successful result when the artefact details match the content item" do
      mag = ManualArtefactGuarantor.new('a-manual-with-artefact')
      response = mag.guarantee
      assert_equal true, response.success?
      assert_match /artefact already exists/, response.message
      assert_match /#{Regexp.escape(@manual_item['content_id'])}/, response.message
    end

    should "return an unsuccessful result if the artefact format does not match the content item" do
      @artefact.update_attributes!(kind: 'detailed_guide')
      mag = ManualArtefactGuarantor.new('a-manual-with-artefact')
      response = mag.guarantee
      assert_equal false, response.success?
      assert_match /artefact details do not match/, response.message
      assert_match /#{Regexp.escape(@manual_item['content_id'])}/, response.message
    end

    should "return an unsuccessful result if the artefact slug does not match the content item" do
      @artefact.update_attributes!(slug: 'guidance/a-different-manual')
      mag = ManualArtefactGuarantor.new('a-manual-with-artefact')
      response = mag.guarantee
      assert_equal false, response.success?
      assert_match /artefact details do not match/, response.message
      assert_match /#{Regexp.escape(@manual_item['content_id'])}/, response.message
    end
  end

  context 'when there is no artefact for the slug' do
    setup do
      @manual_item = manual_item('a-manual-with-artefact')
      content_store_has_item('/guidance/a-manual-with-artefact', @manual_item)
    end

    should "return a successful result after creating one without error" do
      mag = ManualArtefactGuarantor.new('a-manual-with-artefact')
      response = mag.guarantee
      assert_equal true, response.success?
      assert_match /artefact created/, response.message
      assert_match /#{Regexp.escape(@manual_item['content_id'])}/, response.message
    end

    should "return an unsuccessful result if creating one fails" do
      Artefact.any_instance.stubs(:save).returns(false)
      mag = ManualArtefactGuarantor.new('a-manual-with-artefact')
      response = mag.guarantee
      assert_equal false, response.success?
      assert_match /artefact creation failed/, response.message
      assert_match /#{Regexp.escape(@manual_item['content_id'])}/, response.message
    end
  end
end
