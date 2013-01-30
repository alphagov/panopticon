require "artefact"

class Artefact
  # Add a non-field attribute so we can pass indexable content over to Rummager
  # without persisting it
  attr_accessor :indexable_content

  def archived?
    state == 'archived'
  end

  def self.relatable_items
    self.in_alphabetical_order.where(:kind.nin => ["completed_transaction"], :state.nin => ["archived"])
  end
end
