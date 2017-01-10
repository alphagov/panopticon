require 'govuk_content_models/test_helpers/factories'

def create_artefact(owning_app="a-publishing-app")
  FactoryGirl.create(
    :artefact,
    name: 'Child Benefit rates',
    need_ids: ['100001'],
    owning_app: owning_app,
    content_id: SecureRandom.uuid,
  )
end

def create_two_artefacts(owning_app="a-publishing-app")
  [
    'Probation',
    'Leaving prison'
  ].map { |name| FactoryGirl.create :artefact, :name => name, :need_ids => ['100001'], owning_app: owning_app }
end

def submit_artefact_form
  click_button 'Save and go to item'
end

def check_redirect(app, artefact)
  assert_match %r{^#{Regexp.escape Plek.current.find(app)}/}, current_url
  assert_equal artefact.admin_url, current_url
end
