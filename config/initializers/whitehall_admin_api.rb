# This file is replaced on deploy

require 'gds_api/base'
require 'gds_api/whitehall_admin_api'

Panopticon.whitehall_admin_api = GdsApi::WhitehallAdminApi.new(Plek.current.find("whitehall-admin"),
  bearer_token: ENV["panopticon_whitehall_admin_api_bearer_token"] || "not a real bearer token"
)
