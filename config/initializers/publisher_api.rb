# This file is replaced on deploy

require 'gds_api/base'
require 'gds_api/publisher'

Panopticon.publisher_api = GdsApi::Publisher.new(Plek.current.find("publisher"),
  bearer_token: ENV["panopticon_publisher_api_bearer_token"] || "not a real bearer token"
)
