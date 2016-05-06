class ParameterExtractor
  def initialize(params)
    @params = params
  end

  def extract
    params = @params

    fields_to_update = [
      "primary_section",
      "indexable_content",
      "sections" => [],
      "specialist_sectors" => [],
      "related_artefact_slugs" => [],
      "external_links_attributes" => [:title, :url, :id, :_destroy],
    ] + Artefact.fields.map {|k,v| v.type == Array ? { k => [] } : k }

    parameters_to_use = params[:artefact]

    # Partly for legacy reasons, the API can receive live=true
    if live_param = parameters_to_use[:live]
      if ["true", true, "1"].include?(live_param)
        parameters_to_use[:state] = "live"
      end
    end

    # Convert nil tag fields to empty arrays if they're present
    Artefact.tag_types.each do |tag_type|
      if parameters_to_use.has_key?(tag_type)
        parameters_to_use[tag_type] ||= []
      end
      fields_to_update << { tag_type => [] }
    end

    # Strip out the empty submit option for sections
    ['sections', 'specialist_sector_ids', 'organisation_ids'].each do |param|
      param_value = parameters_to_use[param]
      param_value.reject!(&:blank?) if param_value
      fields_to_update << { param => [] }
    end

    parameters_to_use.permit(fields_to_update)
  end
end
