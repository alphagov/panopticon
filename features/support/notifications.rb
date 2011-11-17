def flush_notifications
  FakeTransport.instance.flush
end

def latest_notification_with_destination(destination)
  notifications = FakeTransport.instance.notifications
  notifications.reverse.detect { |n| n[:destination] == destination }
end

def check_update_notification(artefact)
  notification = latest_notification_with_destination '/topic/marples.panopticon.artefacts.updated'
  assert_not_nil notification
  assert_equal artefact.slug, notification[:message][:artefact][:slug]
end
