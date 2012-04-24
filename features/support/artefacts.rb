def create_artefact
  Factory.create :artefact, :name => 'Child Benefit rates', :need_id => 1
end

def create_two_artefacts
  [
    'Probation',
    'Leaving prison'
  ].map { |name| Factory.create :artefact, :name => name, :need_id => 1 }
end

def create_six_artefacts
  [
    'Driving disqualifications',
    'Book the practical driving test',
    'Driving before your licence is returned',
    'National Driver Offender Retraining Scheme',
    'Apply for a new driving licence',
    'Get a divorce'
  ].map { |name| Factory.create :artefact, :name => name, :need_id => 1 }
end

def add_related_artefact(artefact, related_artefact)
  artefact.related_artefacts << related_artefact
end

def add_related_artefacts(artefact, related_artefacts)
  related_artefacts.each do |related_artefact|
    add_related_artefact artefact, related_artefact
  end
end

def select_related_artefact(artefact)
  select_within 'Related items', artefact.name
end

def unselect_related_artefact(artefact)
  unselect_within 'Related items', artefact.name
end

def select_related_artefacts(artefacts)
  artefacts.each(&method(:select_related_artefact))
end

def submit_artefact_form
  click_button 'Save and go to item'
end

def check_redirect(app, artefact)
  assert_match %r{^#{Regexp.escape Plek.current.find(app)}/}, current_url
  assert_equal artefact.admin_url, current_url
end
