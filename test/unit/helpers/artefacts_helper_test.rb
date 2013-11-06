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

  context "link_to_view_need" do
    should "render a link to the need" do
      artefact = OpenStruct.new(need_owning_service: "needorama")
      expects(:need_url).with(artefact).returns("http://needorama.dev.gov.uk/a-need")

      expected = "<a href=\"http://needorama.dev.gov.uk/a-need\" class=\"btn btn-primary\" rel=\"external\">View in Needorama</a>"
      assert_equal expected, link_to_view_need(artefact)
    end

    should "not render a link if need_owning_service is nil" do
      artefact = OpenStruct.new(need_owning_service: nil)

      assert_nil link_to_view_need(artefact)
    end
  end
end
