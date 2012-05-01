require 'gds_api/contactotron'

class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field "name",            type: String
  field "postal_address",  type: String
  field "email_address",   type: String
  field "website_url",     type: String
  field "opening_hours",   type: String
  field "contactotron_id", type: Integer
  field "phone_numbers",   type: Array

  validates :name, :presence => true

  def update_from_contactotron
    [ :name, :postal_address, :email_address, :website_url,
      :opening_hours ].each do |k|
      send "#{k}=", data_from_contactotron.send(k)
    end
    self.phone_numbers = data_from_contactotron.phone_numbers.map { |pn|
      { kind: pn.kind, label: pn.label, value: pn.value }
    }
    save!
  end

  def self.in_alphabetical_order
    order_by([[:name, :asc]])
  end

  private
    def contactotron_uri
      URI.join(Plek.current.find('contactotron'), "/contacts/#{contactotron_id}").to_s
    end

    def api_adapter
      GdsApi::Contactotron.new(Plek.current.environment)
    end

    def data_from_contactotron
      @data_from_contactotron ||= api_adapter.contact_for_uri(contactotron_uri)
    end
end
