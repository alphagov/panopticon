require "curated_list"

class CuratedList
  def usable_artefacts
    artefacts.select { |a| ["draft", "live"].include?(a.state) }
  end
end
