def create_contact
  FactoryGirl.create :contact, :name => 'Child Support Agency'
end

def select_contact(contact)
  select contact.name, :from => 'Contact'
end

def unselect_contact(contact)
  select '', :from => 'Contact'
end

def add_contact(artefact, contact)
  artefact.update_attributes! :contact => contact
end
