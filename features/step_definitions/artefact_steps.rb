Given /^((?:"[^"]*"(?:, | and )?)+) (?:is|are) related to "(.*)"$/ do |related_names, name|
  artefact = Artefact.find_by_name!(name)
  max_sort_key = artefact.related_items.maximum(:sort_key) || -1

  related_names.scan(/"([^"]*)"/).flatten.each.with_index(max_sort_key + 1) do |related_name, sort_key|
    artefact.related_items.create! :artefact => Artefact.find_by_name!(related_name), :sort_key => sort_key
  end
end

Given /^no notifications have been sent$/ do
  FakeTransport.instance.flush
end

When /^I am editing "(.*)"$/ do |name|
  visit edit_artefact_path(Artefact.find_by_name!(name))
end

When /^I add "(.*)" as a related item$/ do |name|
  within_fieldset 'Related items' do
    within_select_with_no_selection do
      select name
    end
  end
end

When /^I remove "(.*)" as a related item$/ do |name|
  within_fieldset 'Related items' do
    within_select_with_selection(name) do
      select ''
    end
  end
end

When /^I save my changes$/ do
  click_on 'Satisfy my need'
end

Then /^I should be redirected to "(.*)" on (.*)$/ do |name, app|
  assert_match %r{^#{Regexp.escape Plek.current.find(app)}/}, current_url
  assert_equal Artefact.find_by_name!(name).admin_url, current_url
end

Then /^the rest of the system should be notified that "(.*)" has been updated$/ do |name|
  notifications = FakeTransport.instance.notifications
  assert_not_empty notifications

  notification = notifications.first
  artefact = Artefact.find_by_name!(name)
  assert_equal '/topic/marples.panopticon.artefacts.updated', notification[:destination]
  assert_equal artefact.slug, notification[:message][:artefact][:slug]
end

Then /^the API should say that ((?:"[^"]*"(?:, | and )?)+) (?:is|are) (not )?related to "(.*)"$/ do |related_names, not_related, name|
  artefact = Artefact.find_by_name!(name)
  visit artefact_path(artefact, :format => :js)

  data = JSON.parse(source).with_indifferent_access
  related_slugs = data[:related_items].map { |item| item[:artefact][:slug] }

  related_names.scan(/"([^"]*)"/).flatten.each do |related_name|
    related_artefact = Artefact.find_by_name!(related_name)

    if not_related
      assert_not_include related_slugs, related_artefact.slug
    else
      assert_include related_slugs, related_artefact.slug
    end
  end
end
