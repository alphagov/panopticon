def flush_notifications
  FakeTransport.instance.flush
end

def latest_notification
  notifications = FakeTransport.instance.notifications
  assert_not_empty notifications
  notifications.last
end
