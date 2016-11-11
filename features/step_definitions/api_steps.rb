Then /^the API should say that the artefacts are related$/ do
  assert @artefact.reload.related_artefact_ids.include?(@related_artefact.id)
  assert_requested @request_to_patch_links
end

Then /^the API should say that the artefacts are not related$/ do
  refute @artefact.reload.related_artefact_ids.include?(@related_artefact.id)
end
