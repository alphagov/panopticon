require 'gds_api/contactotron'

class Contact < ActiveRecord::Base
  serialize :phone_numbers

  validates :name, :presence => true

  scope :in_alphabetical_order, order(arel_table[:name].asc)

  def update_from_contactotron
    [ :name, :postal_address, :phone_numbers, :email_address, :website_url,
      :opening_hours ].each do |k|
      send "#{k}=", data_from_contactotron.send(k)
    end
    save!
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
