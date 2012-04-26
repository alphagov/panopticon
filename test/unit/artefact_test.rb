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

  test "should translate kind into internally normalised form" do
    a = Artefact.new(:kind => "benefit / scheme")
    a.normalise
    assert_equal "programme", a.kind
  end

  test "should not translate unknown kinds" do
    a = Artefact.new(:kind => "other")
    a.normalise
    assert_equal "other", a.kind
  end
end
