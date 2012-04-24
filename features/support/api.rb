def artefact_data_from_api(artefact)
  visit artefact_path(artefact, :format => :json)
  JSON.parse(source).with_indifferent_access
end

def related_artefact_ids_from_api(artefact)
  artefact_data_from_api(artefact)[:related_items].map { |related_item| related_item[:artefact][:id] }
end

def contact_id_from_api(artefact)
  artefact_data_from_api(artefact)[:contact].try(:[], :id)
end

def check_artefact_exists_in_api(artefact_or_slug)
  if artefact_or_slug.is_a?(Hash)
    slug = artefact_or_slug[:slug]
  else
    slug = artefact_for_slug
  end
  assert !! api_client.artefact_for_slug(slug)
end

def check_artefact_has_related_artefact_in_api(artefact, related_artefact)
  assert_include related_artefact_ids_from_api(artefact), related_artefact.id.to_s
end

def check_artefact_has_related_artefacts_in_api(artefact, related_artefacts)
  related_artefacts.each do |related_artefact|
    check_artefact_has_related_artefact_in_api artefact, related_artefact
  end
end

def check_artefact_does_not_have_related_artefact_in_api(artefact, unrelated_artefact)
  assert_not_include related_artefact_ids_from_api(artefact), unrelated_artefact.id.to_s
end

def check_artefact_has_contact_in_api(artefact, contact)
  assert_equal contact_id_from_api(artefact), contact.id.to_s
end

def check_artefact_does_not_have_contact_in_api(artefact, contact)
  assert_not_equal contact_id_from_api(artefact), contact.id.to_s
end
