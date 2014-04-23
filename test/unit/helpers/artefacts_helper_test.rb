require_relative '../../test_helper'

class ArtefactsHelperTest < ActiveSupport::TestCase
  include ArtefactsHelper

  context "#manageable_formats" do
    should "exclude formats owned by Whitehall" do
      assert manageable_formats.exclude?('publication')
      assert manageable_formats.exclude?('speech')
    end

    should "exclude formats owned by Panopticon" do
      assert manageable_formats.exclude?('specialist_sector')
    end
  end
end
