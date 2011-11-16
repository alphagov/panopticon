Then /^the API should say that the artefacts are related$/ do
  assert_include related_artefact_ids_from_api(@artefact), @related_artefact.id
end

Then /^the API should say that the artefacts are not related$/ do
  assert_not_include related_artefact_ids_from_api(@artefact), @related_artefact.id
end

Then /^the API should say that more of the artefacts are related$/ do
  related_artefact_ids = related_artefact_ids_from_api(@artefact)

  @related_artefacts.each do |related_artefact|
    assert_include related_artefact_ids, related_artefact.id
  end
  assert_not_include related_artefact_ids, @unrelated_artefact.id
end

Then /^the API should say that the artefact has the contact$/ do
  assert_include contact_ids_from_api(@artefact), @contact.id
end

Then /^the API should say that the artefact does not have the contact$/ do
  assert_not_include contact_ids_from_api(@artefact), @contact.id
end
