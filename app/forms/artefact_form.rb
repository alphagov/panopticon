class ArtefactForm < BasicObject
  def initialize(object)
    @artefact = object
  end

  def specialist_sector_ids
    artefact.specialist_sector_ids(draft: true)
  end

  def specialist_sectors
    artefact.specialist_sectors(draft: true)
  end

  def to_model
    self
  end

  alias_method :send, :__send__

private
  attr_reader :artefact

  def method_missing(method, *args, &block)
    artefact.send(method, *args, &block)
  end
end
