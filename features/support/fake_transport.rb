class FakeTransport
  include Singleton

  attr_reader :notifications

  def initialize
    flush
  end

  def flush
    self.notifications = []
  end

  def publish(destination, message, headers = {})
    notifications << { destination: destination, message: Hash.from_xml(message).with_indifferent_access, headers: headers }
  end

  private
    attr_writer :notifications
end

Messenger.transport = FakeTransport.instance

Before do
  flush_notifications
end
