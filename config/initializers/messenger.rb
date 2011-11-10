require 'messenger'

unless Rails.env.test?
  host = Rails.env.production? ? 'support.cluster' : 'localhost'
  uri = URI::Generic.build scheme: 'stomp', host: host, port: 61613
  Messenger.transport = Stomp::Client.new uri.to_s
end
