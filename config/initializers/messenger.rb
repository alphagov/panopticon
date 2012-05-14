require 'messenger'
require 'marples/model_action_broadcast'
require 'artefact'

class Artefact
  include Marples::ModelActionBroadcast
  self.marples_client_name = 'panopticon'
  self.marples_logger = Rails.logger
end

# Marples config needs to be triggered by on_prepare so it doesn't get merrily
# blatted whenever the Artefact model reloads in development mode
Panopticon::Application.config.to_prepare do
  if Rails.env.test? or ENV['NO_MESSENGER'].present?
    Messenger.transport = Marples::NullTransport.instance
    Artefact.marples_transport = Marples::NullTransport.instance
  else
    stomp_url = "failover://(stomp://support.cluster:61613,stomp://support.cluster:61613)"

    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        if forked
          Messenger.transport = Stomp::Client.new stomp_url
          Artefact.marples_transport = Stomp::Client.new stomp_url
        end
      end
    else
      Messenger.transport = Stomp::Client.new stomp_url
      Artefact.marples_transport = Stomp::Client.new stomp_url
    end
  end
end
