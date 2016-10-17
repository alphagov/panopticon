class ParameterExtractor
  # https://github.com/rails/strong_parameters#permitted-scalar-values
  ALLOWED_FIELDS = [
    :_id,
    :active,
    :content_id,
    :created_at,
    :description,
    :kind,
    :language,
    :latest_change_note,
    :name,
    :need_id,
    :owning_app,
    :primary_section,
    :public_timestamp,
    :publication_id,
    :redirect_url,
    :rendering_app,
    :slug,
    :state,
    :updated_at,

    keywords: [],
    need_ids: [],
    paths: [],
    prefixes: [],
    propositions: [],
    related_artefact_ids: [],
    related_artefact_slugs: [],
    writing_teams: [],
  ].freeze

  # The last element is actually a hash of all the elements with an array-type.
  # Paste this into a console if you don't believe it.
  ALLOWED_FIELD_NAMES = ALLOWED_FIELDS[0..-1] + ALLOWED_FIELDS.last.keys

  def initialize(params)
    @params = params
  end

  def extract
    prepared_parameters.permit(ALLOWED_FIELDS)
  end

private

  def prepared_parameters
    params = @params[:artefact]

    # Convert comma separated values into arrays
    %w[need_ids related_artefact_slugs].each do |attribute|
      next if params[attribute].nil? || params[attribute].is_a?(Array)
      params[attribute] = params[attribute].split(",").map(&:strip).reject(&:blank?)
    end

    # For legacy reasons, the API can receive live=true
    if params[:live].in?(["true", true, "1"])
      params[:state] = "live"
    end

    params
  end
end
