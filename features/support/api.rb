def artefact_data_from_api(artefact)
  get artefact_path(artefact, :format => :json)
  JSON.parse(last_response.body).with_indifferent_access
end

def related_artefact_ids_from_api(artefact)
  artefact_data_from_api(artefact)[:related_items].map { |related_item| related_item[:artefact][:id] }
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
