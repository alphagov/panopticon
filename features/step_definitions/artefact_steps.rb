When /^I am editing "(.*)"$/ do |name|
  visit edit_artefact_path(Artefact.find_by_name(name))
end
