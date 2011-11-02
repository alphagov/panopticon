class Contact < ActiveRecord::Base
  validates :name, :presence => true
end
