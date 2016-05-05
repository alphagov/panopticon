class RelatableItems
  def initialize(params)
    @params = params
  end

  def relatable_items
    artefacts = Artefact.relatable_items_like(params[:title_substring]).page(params[:page]).per(15)
    artefacts_map = { artefacts: artefacts.map {|a| { id: a.slug, text: a.name_with_owner_prefix } } }
    artefacts_map.merge(total: artefacts.total_count)
  end

private

  attr_reader :params
end
