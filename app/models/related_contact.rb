class RelatedContact < ActiveRecord::Base
  belongs_to :artefact
  belongs_to :contact

  validates :artefact, :contact, :sort_key, :presence => true
end
