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

Then /^the API should say that the artefact has the section$/ do
  check_artefact_has_tag_in_api @artefact, @section.tag_id
end

Then /^the API should say that the artefact has the first section$/ do
  check_artefact_has_tag_in_api @artefact, @sections[0].tag_id
end

Then /^the API should say that the artefact does not have the section$/ do
  check_artefact_does_not_have_tag_in_api @artefact, @section.tag_id
end

Then /^the API should say that the artefact does not have the second section$/ do
  check_artefact_does_not_have_tag_in_api @artefact, @sections[1].tag_id
end
