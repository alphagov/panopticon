require "artefact"

class Artefact
  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  STATES = [ "live", "draft", "archived" ]

  MASLOW_NEED_ID_LOWER_BOUND = 100000

  def need_id_numeric?
    self.need_id.strip =~ /\A\d+\z/
  end

  def need_owning_service
    return nil unless self.need_id.present? and self.need_id.match(/\A[0-9]+\Z/)
    self.need_id.to_i < MASLOW_NEED_ID_LOWER_BOUND ? "needotron" : "maslow"
  end

  def need
    return unless need_owning_service == "maslow"

    @need ||= Panopticon.need_api.need(need_id)
  rescue GdsApi::BaseError
  end
end
