Given /^a contact exists$/ do
  @contact = create_contact
  flush_notifications
end
