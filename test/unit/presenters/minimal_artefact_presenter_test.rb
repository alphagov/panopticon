require_relative '../../test_helper'

class MinimalArtefactPresenterTest < ActiveSupport::TestCase

  context "with an artefact" do
    setup do
      @artefact = Artefact.new(
        id: 12,
        slug: "cheese-benefit",
        name: "Cheese benefit",
        owning_app: "publisher",
      )
      @presenter = MinimalArtefactPresenter.new(@artefact)
    end

    should "present the artefact as a hash" do
      assert @presenter.as_json.is_a? Hash
    end

    should "include the name, slug and owning app" do
      assert_equal "Cheese benefit", @presenter.as_json[:name]
      assert_equal "cheese-benefit", @presenter.as_json[:slug]
      assert_equal "publisher", @presenter.as_json[:owning_app]
    end

    should "not include any tag information" do
      refute @presenter.as_json.include? :tag_ids
      refute @presenter.as_json.include? :tags
    end
  end

end
