require "abstract_listener"

class ContactListener < AbstractListener

  listen 'contactotron', '*', 'created' do |message, logger|
    logger.info "Creating contact #{message['id']}"
    contact = Contact.find_or_initialize_by_contactotron_id(message['id'])
    contact.update_from_contactotron
  end

  listen 'contactotron', '*', 'updated' do |message, logger|
    logger.info "Updating contact #{message['id']}"
    contact = Contact.find_or_initialize_by_contactotron_id(message['id'])
    contact.update_from_contactotron
  end
end
