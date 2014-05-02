require 'govuk_content_models/test_helpers/factories'

def create_artefact
  FactoryGirl.create :artefact, :name => 'Child Benefit rates', :need_ids => ['100001']
end

def create_two_artefacts(owning_app="publisher")
  [
    'Probation',
    'Leaving prison'
  ].map { |name| FactoryGirl.create :artefact, :name => name, :need_ids => ['100001'], owning_app: owning_app }
end

def create_six_artefacts(owning_app="publisher")
  [
    'Driving disqualifications',
    'Book the practical driving test',
    'Driving before your licence is returned',
    'National Driver Offender Retraining Scheme',
    'Apply for a new driving licence',
    'Get a divorce'
  ].map { |name| FactoryGirl.create :artefact, :name => name, :need_ids => ['100001'], owning_app: owning_app }
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
  fill_in "s2id_autogen2", with: artefact.name
  find(".select2-result-label", match: :first).click
end

def unselect_related_artefact(artefact)
  page.execute_script(%Q<$("li:contains('#{artefact.name}') .select2-search-choice-close").click();>)
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
