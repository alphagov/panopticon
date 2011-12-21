Then /^the API should say that the artefact exists$/ do
  check_artefact_exists_in_api @artefact
end

Then /^the API should say that the artefacts are related$/ do
  check_artefact_has_related_artefact_in_api @artefact, @related_artefact
end

Then /^the API should say that the artefacts are not related$/ do
  check_artefact_does_not_have_related_artefact_in_api @artefact, @related_artefact
end

Then /^the API should say that more of the artefacts are related$/ do
  check_artefact_has_related_artefacts_in_api @artefact, @related_artefacts
  check_artefact_does_not_have_related_artefact_in_api @artefact, @unrelated_artefact
end

Then /^the API should say that the artefact has the contact$/ do
  check_artefact_has_contact_in_api @artefact, @contact
end

Then /^the API should say that the artefact does not have the contact$/ do
  check_artefact_does_not_have_contact_in_api @artefact, @contact
end
