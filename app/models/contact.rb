class Contact < ActiveRecord::Base
  validates :name, :presence => true

  scope :in_alphabetical_order, order('name ASC')
end
