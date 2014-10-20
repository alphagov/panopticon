class SpecialistSectorTagForm < BasicObject
  def initialize(*args)
    @tag = ::Tag.new(*args)
  end

  def valid?
    tag.valid? && artefact.valid?
  end

  def errors
    tag.errors.tap do |tag_errors|
      if tag_errors[:tag_id].empty? && artefact.errors[:slug].any?
        artefact.errors[:slug].each do |slug_error|
          tag_errors.add(:tag_id, slug_error)
        end
      end
    end
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
      paths: paths,
      prefixes: prefixes,
      kind: "specialist_sector",
      owning_app: "panopticon",
      rendering_app: "collections",
      state: tag.state,
    }
  end

  def slug
    tag.tag_id
  end

  def paths
    child? ? [] : ["/#{slug}"]
  end

  def prefixes
    child? ? ["/#{slug}"] : []
  end

  def child?
    slug.include?('/')
  end
end
