require "artefact"

class Artefact
  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  def need_id_editable?
    self.new_record? || self.need_id.blank? || self.need_id.strip !~ /\A\d+\z/
  end
end
