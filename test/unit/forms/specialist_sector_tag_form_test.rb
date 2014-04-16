require_relative '../../test_helper'

class SpecialistSectorTagFormTest < ActiveSupport::TestCase
  context '#valid?' do
    subject do
      SpecialistSectorTagForm.new(
        title: 'Oil and gas',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas',
      )
    end

    context 'with an unused slug' do
      should 'be true' do
        assert subject.valid?
      end
    end

    context 'with an already taken slug' do
      setup do
        FactoryGirl.create(:artefact, slug: 'oil-and-gas')
      end

      should 'be false' do
        refute subject.valid?
      end
    end

    context 'with a two-part slug' do
      setup do
        FactoryGirl.create(:artefact, slug: 'oil-and-gas')
      end

      subject do
        SpecialistSectorTagForm.new(
          title: 'Fields and wells',
          tag_type: 'specialist_sector',
          tag_id: 'oil-and-gas/fields-and-wells',
        )
      end
    end
  end

  context '#save' do
    setup do
      stub_all_router_api_requests
      stub_all_rummager_requests
    end

    subject do
      SpecialistSectorTagForm.new(
        title: 'Oil and gas',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas',
      )
    end

    should 'create an artefact for the tag' do
      assert_difference 'Artefact.count', 1 do
        subject.save
      end

      artefact = Artefact.last

      assert_equal 'specialist_sector', artefact.kind
      assert_equal 'panopticon', artefact.owning_app
      assert_equal 'collections', artefact.rendering_app
      assert_equal 'Oil and gas', artefact.name
      assert_equal 'oil-and-gas', artefact.slug
      assert_equal ['/oil-and-gas'], artefact.paths
      assert_equal 'live', artefact.state
    end
  end
end