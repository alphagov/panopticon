require 'open-uri'

class Contact < ActiveRecord::Base
  serialize :phone_numbers

  validates :name, :presence => true

  scope :in_alphabetical_order, order('name ASC')

  def update_from_contactotron
    update_attributes! data_from_contactotron.slice(:name, :postal_address, :phone_numbers, :email_address, :website_url, :opening_hours)
  end

  private
    def contactotron_uri
      URI.parse(Plek.current.find('contactotron')).tap do |uri|
        uri.path = "/contacts/#{contactotron_id}.json"
      end
    end

    def json_from_contactotron
      open(contactotron_uri.to_s).read
    end

    def data_from_contactotron
      ActiveSupport::JSON.decode(json_from_contactotron).with_indifferent_access
    end
end
