module ArtefactsHelper
  def need_url(artefact)
    Plek.current.find('needotron') + "/needs/#{artefact.need_id}"
  end

  def published_url(artefact)
    Plek.current.website_root + "/#{artefact.slug}"
  end

  def human_timestamp(timestamp)
    timestamp ? timestamp.strftime("%d/%m/%Y %R") : "(no timestamp)"
  end

  def name_hint_for(artefact)
    artefact.persisted? ? "This should be edited in #{artefact.owning_app}" : "A name/title for the item"
  end

  def non_whitehall_formats
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP.each_with_object([]) do |(owning_app, formats), result|
      if owning_app != "whitehall"
        result.concat(formats)
      end
    end
  end
end
