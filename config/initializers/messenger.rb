require 'active_record_ext'
require 'messenger'
unless Rails.env.test?
  stomp_url = "failover://(stomp://support.cluster:61613,stomp://support.cluster:61613)"
  ActiveRecord::Base.marples_client_name = 'panopticon'
  ActiveRecord::Base.marples_logger = Rails.logger

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      if forked
        Messenger.transport = Stomp::Client.new stomp_url    
        ActiveRecord::Base.marples_transport = Stomp::Client.new stomp_url
      end
    end
  else
    Messenger.transport = Stomp::Client.new stomp_url
    ActiveRecord::Base.marples_transport = Stomp::Client.new stomp_url
  end
end
