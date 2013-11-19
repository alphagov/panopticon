require "artefact"

class Artefact
  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  def need_id_editable?
    self.new_record? || self.need_id.blank? || self.need_id.strip !~ /\A\d+\z/ || self.need_id.to_i < 100000
  end

  def need_owning_service
    return nil unless self.need_id.present? and self.need_id.match(/\A[0-9]+\Z/)
    self.need_id.to_i < 100000 ? "needotron" : "maslow"
  end
end
