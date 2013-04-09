require "curated_list"

class CuratedList
  def usable_artefacts
    artefacts.reject { |a| a.archived? }
  end
end
