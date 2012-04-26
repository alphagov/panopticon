require 'test_helper'

class ArtefactTest < ActiveSupport::TestCase
  test "it allows nice clean slugs" do
    a = Artefact.new(:slug => "its-a-nice-day")
    a.valid?
    assert a.errors[:slug].empty?
  end

  test "it doesn't allow apostrophes in slugs" do
    a = Artefact.new(:slug => "it's-a-nice-day")
    assert ! a.valid?
    assert a.errors[:slug].any?
  end

  test "it doesn't allow spaces in slugs" do
    a = Artefact.new(:slug => "it is-a-nice-day")
    assert ! a.valid?
    assert a.errors[:slug].any?
  end
end
