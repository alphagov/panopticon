require 'govuk_content_models/test_helpers/factories'

def create_artefact
  FactoryGirl.create :artefact, :name => 'Child Benefit rates', :need_id => 1
end

def create_two_course_artefacts
  f = FactoryGirl.create(:artefact, :name => "An course", :slug => 'an-course', :owning_app => "publisher", :kind => "course", :state => "live")
  f2 =FactoryGirl.create(:artefact, :name => "An other course", :slug => "an-other-course", :owning_app => "publisher", :kind => "course", :state => "live")
  course = CourseEdition.create(:title => "Course Edition",
                              :panopticon_id => f2.id,
                              :length => "5 Days",
                              :description => "This is an awesome course",
                              :state => "published")
  [f, f2]
end

def create_two_artefacts(owning_app="publisher")
  [
    'Probation',
    'Leaving prison'
  ].map { |name| FactoryGirl.create :artefact, :name => name, :need_id => 1, owning_app: owning_app }
end

def create_six_artefacts(owning_app="publisher")
  [
    'Driving disqualifications',
    'Book the practical driving test',
    'Driving before your licence is returned',
    'National Driver Offender Retraining Scheme',
    'Apply for a new driving licence',
    'Get a divorce'
  ].map { |name| FactoryGirl.create :artefact, :name => name, :need_id => 1, owning_app: owning_app }
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
  select artefact.name, :from => "artefact_related_artefact_ids_"
end

def unselect_related_artefact(artefact)
  within(:xpath, "//option[@value='#{artefact.id}'][@selected='selected']/../..") do
    # Can't rely on the Remove button here, as JavaScript may not have loaded
    # and the buttons aren't full of progressive enhancement goodness
    select "Select a related item", from: "artefact_related_artefact_ids_"
  end
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
