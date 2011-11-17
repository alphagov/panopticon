def create_contact
  Factory.create :contact, :name => 'Child Support Agency'
end

def select_contact(contact)
  select_within 'Contacts', contact.name
end

def unselect_contact(contact)
  unselect_within 'Contacts', contact.name
end

def add_contact(artefact, contact)
  artefact.related_contacts.create! :contact => contact, :sort_key => (artefact.related_contacts.maximum(:sort_key) || -1) + 1
end
