def artefact_data_from_api(artefact)
  visit artefact_path(artefact, :format => :js)
  JSON.parse(source).with_indifferent_access
end

def related_artefact_ids_from_api(artefact)
  artefact_data_from_api(artefact)[:related_items].map { |related_item| related_item[:artefact][:id] }
end

def contact_ids_from_api(artefact)
  artefact_data_from_api(artefact)[:contacts].map { |contact| contact[:id] }
end

def check_artefact_has_related_artefact_in_api(artefact, related_artefact)
  assert_include related_artefact_ids_from_api(artefact), related_artefact.id
end

def check_artefact_has_related_artefacts_in_api(artefact, related_artefacts)
  related_artefacts.each do |related_artefact|
    check_artefact_has_related_artefact_in_api artefact, related_artefact
  end
end

def check_artefact_does_not_have_related_artefact_in_api(artefact, unrelated_artefact)
  assert_not_include related_artefact_ids_from_api(artefact), unrelated_artefact.id
end

def check_artefact_has_contact_in_api(artefact, contact)
  assert_include contact_ids_from_api(artefact), contact.id
end

def check_artefact_does_not_have_contact_in_api(artefact, contact)
  assert_not_include contact_ids_from_api(artefact), contact.id
end
