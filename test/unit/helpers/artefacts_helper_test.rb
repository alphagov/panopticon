require_relative '../../test_helper'

class ArtefactsHelperTest < ActionView::TestCase
  include ArtefactsHelper

  context "need_url" do
    should "build a url from the need_owning_service" do
      artefact = OpenStruct.new(need_owning_service: "needorama", need_id: "123456")

      assert_equal "http://needorama.dev.gov.uk/needs/123456", need_url(artefact)
    end

    should "return nil if need_owning_service is nil" do
      artefact = OpenStruct.new(need_owning_service: nil, need_id: "malformed need ID")

      assert_nil need_url(artefact)
    end
  end
end
