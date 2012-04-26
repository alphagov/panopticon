class RelatedItem < ActiveRecord::Base
  belongs_to :source_artefact, :class_name => 'Artefact'
  belongs_to :artefact, :counter_cache => true

  validates_uniqueness_of :source_artefact_id, :scope => :artefact_id
end
