require_relative '../../test_helper'

class TagsHelperTest < ActiveSupport::TestCase
  include TagsHelper

  context "grouped_options_for_tags_of_type" do
    setup do
      Tag.create!(tag_type: "section", tag_id: "tax", title: "Tax")
      Tag.create!(tag_type: "section", tag_id: "driving", title: "Driving")
      Tag.create!(tag_type: "section", tag_id: "driving/car-tax", title: "Car tax", parent_id: "driving")
      Tag.create!(tag_type: "section", tag_id: "driving/mot", title: "MOT", parent_id: "driving")
    end

    should "return a hierarchy of parent tags and their children" do
      expected = [
        [ "Driving", [ ["Driving: Car tax", "driving/car-tax"], ["Driving: MOT", "driving/mot"] ]]
      ]

      assert_equal expected, grouped_options_for_tags_of_type("section")
    end
  end

end
