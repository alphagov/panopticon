require_relative '../test_helper'

class DiffEnabledActionTest < ActiveSupport::TestCase

  test "should report being an initial action" do
    action = ArtefactAction.new(
      action_type: "update",
      snapshot: {}
    )
    a = DiffEnabledAction.new(action, nil)
    assert a.initial?
  end

  test "should show no changes from itself" do
    action = ArtefactAction.new(
      action_type: "update",
      snapshot: {}
    )
    a = DiffEnabledAction.new(action, action)
    refute a.initial?
    assert a.changed_keys.empty?
    assert a.changes.empty?
  end

  test "should show changes" do
    first_action = ArtefactAction.new(
      action_type: "update",
      snapshot: {"cheese" => 1, "walrus" => "I am a string"}
    )
    second_action = ArtefactAction.new(
      action_type: "update",
      snapshot: {"cheese" => 1, "walrus" => "I am another string"}
    )
    a = DiffEnabledAction.new(second_action, first_action)
    assert_equal ["walrus"], a.changed_keys
    assert_equal(
      {"walrus" => ["I am a string", "I am another string"]},
      a.changes
    )
  end

  test "should handle removed keys" do
    first_action = ArtefactAction.new(
      action_type: "update",
      snapshot: {"cheese" => 1, "walrus" => "I am a string"}
    )
    second_action = ArtefactAction.new(
      action_type: "update",
      snapshot: {"cheese" => 1}
    )
    a = DiffEnabledAction.new(second_action, first_action)
    assert_equal ["walrus"], a.changed_keys
    assert_equal(
      {"walrus" => ["I am a string", nil]},
      a.changes
    )
  end

  test "should handle added keys" do
    first_action = ArtefactAction.new(
      action_type: "update",
      snapshot: {"cheese" => 1}
    )
    second_action = ArtefactAction.new(
      action_type: "update",
      snapshot: {"cheese" => 1, "walrus" => "I am a string"}
    )
    a = DiffEnabledAction.new(second_action, first_action)
    assert_equal ["walrus"], a.changed_keys
    assert_equal(
      {"walrus" => [nil, "I am a string"]},
      a.changes
    )
  end

end
