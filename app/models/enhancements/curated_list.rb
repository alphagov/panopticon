require "curated_list"

class CuratedList
  def usable_artefacts
    artefacts.reject(&:archived?)
  end
end
