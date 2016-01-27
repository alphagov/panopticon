class DiffEnabledAction
  # Decorator for the ArtefactAction class, which can express what has changed.

  extend Forwardable

  def_delegators :@action, :action_type, :snapshot, :created_at, :user

  def initialize(action, previous = nil)
    @action = action
    @previous = previous
  end

  def initial?
    ! @previous
  end

  def changes
    # If this is an initial action, fake out the previous snapshot as an empty
    # hash, for consistency with the general case
    previous_snapshot = @previous ? @previous.snapshot : {}
    snapshots = [previous_snapshot, @action.snapshot]

    changed_keys.reduce({}) { |changes, key|
      changes.merge key => snapshots.map { |snapshot| snapshot[key] }
    }
  end

  def changed_keys
    return @action.snapshot.keys unless @previous

    (@action.snapshot.keys | @previous.snapshot.keys).reject { |key|
      @action.snapshot[key] == @previous.snapshot[key]
    }
  end
end
