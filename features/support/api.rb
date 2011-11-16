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
