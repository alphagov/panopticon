When /^I am editing "(.*)"$/ do |name|
  visit edit_artefact_path(Artefact.find_by_name(name))
end

When /^I add "(.*)" as a related item$/ do |name|
  within_fieldset 'Related items' do
    within :xpath, './/select[not(option[@selected])]' do
      select name
    end
  end
end

When /^I save my changes$/ do
  click_on 'Satisfy my need'
end

Then /^I should be redirected to "(.*)" on (.*)$/ do |name, app|
  assert_match %r{^#{Regexp.escape Plek.current.find(app)}/}, current_url
  assert_equal Artefact.find_by_name(name).admin_url, current_url
end

Then /^the rest of the system should be notified that "(.*)" has been updated$/ do |name|
  notifications = FakeTransport.instance.notifications
  assert_not_empty notifications

  notification = notifications.first
  artefact = Artefact.find_by_name(name)
  assert_equal '/topic/marples.panopticon.artefacts.updated', notification[:destination]
  assert_equal artefact.slug, notification[:message][:artefact][:slug]
end

Then /^the API should say that "(.*)" is related to "(.*)"$/ do |related_name, name|
  artefact, related_artefact = [name, related_name].map { |n| Artefact.find_by_name(n) }
  visit artefact_path(artefact, :format => :js)

  data = JSON.parse(source).with_indifferent_access
  related_slugs = data[:related_items].map { |item| item[:artefact][:slug] }
  assert_include related_slugs, related_artefact.slug
end
