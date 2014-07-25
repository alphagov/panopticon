require_relative '../../test_helper'

class ArtefactFormTest < ActiveSupport::TestCase

  setup do
    @artefact = mock('Artefact')
  end

  subject do
    ArtefactForm.new(@artefact)
  end

  should 'send requests to the artefact' do
    @artefact.expects(:foo).returns('bar')

    assert_equal 'bar', subject.foo
  end

  should 'return itself for #to_model' do
    assert_equal subject, subject.to_model
  end

  context '#specialist_sector_ids' do
    should 'call the artefact, including the draft argument' do
      @artefact.expects(:specialist_sector_ids).with(has_entry(:draft, true)).returns('foo')

      assert_equal 'foo', subject.specialist_sector_ids
    end
  end

  context '#specialist_sectors' do
    should 'call the artefact, including the draft argument' do
      @artefact.expects(:specialist_sectors).with(has_entry(:draft, true)).returns('foo')

      assert_equal 'foo', subject.specialist_sectors
    end
  end

  context '#section_ids' do
    should 'call the artefact, including the draft argument' do
      @artefact.expects(:section_ids).with(has_entry(:draft, true)).returns('foo')

      assert_equal 'foo', subject.section_ids
    end
  end

  context '#sections' do
    should 'call the artefact, including the draft argument' do
      @artefact.expects(:sections).with(has_entry(:draft, true)).returns('foo')

      assert_equal 'foo', subject.sections
    end
  end
end
