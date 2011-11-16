def flush_notifications
  FakeTransport.instance.flush
end

def latest_notification
  notifications = FakeTransport.instance.notifications
  assert_not_empty notifications
  notifications.last
end

def check_update_notification(artefact)
  assert_equal '/topic/marples.panopticon.artefacts.updated', latest_notification[:destination]
  assert_equal artefact.slug, latest_notification[:message][:artefact][:slug]
end
