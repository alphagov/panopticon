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

  should "return an unsuccessful result if the slug does not exist in the content store" do
    content_store_does_not_have_item('/guidance/missing-item')

    mag = ManualArtefactGuarantor.new('missing-item')
    response = mag.guarantee
    assert_equal false, response.success?
    assert_match /does not exist/, response.message
  end
end
