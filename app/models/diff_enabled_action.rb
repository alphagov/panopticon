class DiffEnabledAction

  # Decorator for the ArtefactAction class, which can express what has changed.

  extend Forwardable

  def_delegators :@action, :action_type, :snapshot, :created_at, :user

  def initialize(action, previous = nil)
    @action, @previous = action, previous
  end

  def initial?
    ! @previous
  end

  def changes
    return @action.snapshot unless @previous

    changed_keys.reduce({}) { |changes, key|
      changes.merge key => [@previous, @action].map { |a| a.snapshot[key] }
    }
  end

  def changed_keys
    return @action.snapshot.keys unless @previous

    (@action.snapshot.keys | @previous.snapshot.keys).reject { |key|
      @action.snapshot[key] == @previous.snapshot[key]
    }
  end
end
