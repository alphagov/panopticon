class SpecialistSectorTagForm < BasicObject
  def initialize(*args)
    @tag = ::Tag.new(*args)
  end

  def valid?
    tag.valid? && artefact.valid?
  end

  def save
    valid? && tag.save && artefact.save
  end

private
  attr_reader :tag

  def method_missing(method, *args, &block)
    tag.send(method, *args, &block)
  end

  def artefact
    @artefact ||= ::Artefact.new(artefact_attributes)
  end

  def artefact_attributes
    {
      name: tag.title,
      slug: slug,
      paths: ["/#{slug}"],
      kind: "specialist_sector",
      owning_app: "panopticon",
      rendering_app: "collections",
      state: "live"
    }
  end

  def slug
    tag.tag_id
  end
end
