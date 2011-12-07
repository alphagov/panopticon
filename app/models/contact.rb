require 'gds_api/contactotron'

class Contact < ActiveRecord::Base
  serialize :phone_numbers

  validates :name, :presence => true

  scope :in_alphabetical_order, order(arel_table[:name].asc)

  def update_from_contactotron
    update_attributes! [:name, :postal_address, :phone_numbers, :email_address, :website_url, :opening_hours].collect { |k| data_from_contactotron.send(k) }
  end

  private
    def contactotron_uri
      URI.parse(Plek.current.find('contactotron')).tap do |uri|
        uri.path = "/contacts/#{contactotron_id}"
      end
    end

    def api_adapter
      GdsApi::Contactotron.new
    end

    def data_from_contactotron
      @data_from_contactotron ||= api_adapter.contact_for_uri(contactotron_uri)
    end
end
