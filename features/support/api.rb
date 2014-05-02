def artefact_data_from_api(artefact)
  get artefact_path(artefact, :format => :json)
  JSON.parse(last_response.body).with_indifferent_access
end

def related_artefact_ids_from_api(artefact)
  artefact_data_from_api(artefact)[:related_items].map { |related_item| related_item[:artefact][:id] }
end

def tag_ids_from_api(artefact)
  artefact_data_from_api(artefact)[:tag_ids]
end

def check_artefact_exists_in_api(artefact_or_slug)
  if artefact_or_slug.is_a?(Hash)
    slug = artefact_or_slug[:slug]
  else
    slug = artefact_for_slug
  end
  assert !! api_client.artefact_for_slug(slug)
end

def check_artefact_has_name_in_api(artefact, name)
  assert_equal name, artefact_data_from_api(artefact)[:name]
end

def check_artefact_has_related_artefact_in_api(artefact, related_artefact)
  assert_includes related_artefact_ids_from_api(artefact), related_artefact.id.to_s
end

def check_artefact_has_related_artefacts_in_api(artefact, related_artefacts)
  related_artefacts.each do |related_artefact|
    check_artefact_has_related_artefact_in_api artefact, related_artefact
  end
end

def check_artefact_does_not_have_related_artefact_in_api(artefact, unrelated_artefact)
  refute_includes related_artefact_ids_from_api(artefact), unrelated_artefact.id.to_s
end

def check_artefact_has_tag_in_api(artefact, tag_id)
  assert_includes tag_ids_from_api(artefact), tag_id
end

def check_artefact_does_not_have_tag_in_api(artefact, tag_id)
  refute_includes tag_ids_from_api(artefact), tag_id
end
